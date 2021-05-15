module Layout
  module Parser
    class Tokenizer
      enum Token
        DOCTYPE
        START_TAG
        END_TAG
        COMMENT
        CHARACTER
        EOF
      end

      property custom_components = {} of String => Layout::Dom::Node

      def initialize(text : String)
        @text = text
        @position = 0
      end

      def peek
        @text[@position]
      end

      def peek_again
        @text[@position + 1]
      end

      def peek_twice
        @text[@position + 2]
      end

      def starts_with?(sequence)
        @text[@position..(@position + sequence.bytesize - 1)] == sequence
      end

      def eof?
        @position >= @text.bytesize
      end

      def next_char
        output = @text[@position]
        @position += 1
        output
      end

      def next_while(&blk)
        result = ""

        while !eof? && yield peek
          result += next_char
        end

        result
      end

      def skip_whitespace
        next_while do |char|
          char.ascii_whitespace?
        end
      end

      def parse_bare_word
        next_while do |char|
          char.alphanumeric?
        end
      end

      def is_closing_tag?
        starts_with?("</")
      end

      def parse_node : Layout::Dom::Node?
        case peek
        when '<'
          parse_element
        else
          parse_text
        end
      end

      def parse_text : Layout::Dom::Node
        contents = next_while { |c| c != '<' }
        Layout::Dom::Text.new(contents)
      end

      # ameba:disable Metrics/CyclomaticComplexity
      def parse_element : Layout::Dom::Node?
        children = [] of Layout::Dom::Node

        assert!(next_char == '<', @position)

        if next_char == '!'
          assert!(next_char == '-', @position)
          assert!(next_char == '-', @position)

          return parse_comment
        end

        @position -= 1

        tag_name = parse_bare_word
        attrs = parse_attributes

        if next_char == '/'
          assert!(next_char == '>', @position)
          case tag_name
          when "Import"
            begin
              custom_components[attrs["as"].not_nil!] = Layout::Dom::Import.new(attrs)
            rescue exception
              case exception
              when Enumerable::EmptyError
                raise Exceptions::EmptyComponentException.new
              else
                raise exception
              end
            end

            nil
          when "StyleSheet"
            Layout::Dom::StyleSheet.new(attrs)
          when "Script"
            Layout::Dom::Script.new(attrs, children)

            nil
          when "TextInput"
            Layout::Dom::TextInput.new(attrs)
          when "Image"
            Layout::Dom::Image.new(attrs)
          when "Switch"
            Layout::Dom::Switch.new(attrs)
          else
            if child = custom_components[tag_name]?
              child = child.as(Layout::Dom::Element)
              begin
                File.open(child.attributes["src"].not_nil!) do |fd|
                  element = Parser.parse(fd.gets_to_end).as(Layout::Dom::Export)

                  if element.attributes["as"].not_nil! == child.attributes["as"].not_nil!
                    case element.children.first
                    when Layout::Dom::StyleSheet
                      element.children[1].children.push(element.children.first)
                      child = element.children[1].as(Layout::Dom::Element)
                      child.attributes.merge!(attrs)
                      child.on_component_did_mount
                      child
                    else
                      child = element.children.first.as(Layout::Dom::Element)
                      child.attributes.merge!(attrs)
                      child.on_component_did_mount
                      child
                    end
                  else
                    raise Exceptions::ImportNotFoundException.new(child.attributes["src"].not_nil!, child.attributes["as"].not_nil!, element.attributes["as"].not_nil!)
                  end
                end
              rescue exception
                case exception
                when Enumerable::EmptyError
                  raise Exceptions::EmptyComponentException.new
                else
                  raise exception
                end
              end
            else
              raise Exceptions::InvalidElementException.new(tag_name, @position)
            end
          end
        else
          children = parse_nodes
          assert!(next_char == '<', @position)
          assert!(next_char == '/', @position)
          assert!(parse_bare_word == tag_name, @position)
          assert!(next_char == '>', @position)

          case tag_name
          when "Script"
            Layout::Dom::Script.new(attrs, children)

            nil
          when "Application"
            Layout::Dom::Application.new(attrs, children)
          when "Window"
            Layout::Dom::Window.new(attrs, children)
          when "Box"
            Layout::Dom::Box.new(attrs, children)
          when "Tab"
            Layout::Dom::Tab.new(attrs, children)
          when "EventBox"
            Layout::Dom::EventBox.new(attrs, children)
          when "Button"
            Layout::Dom::Button.new(attrs, children)
          when "Label"
            Layout::Dom::Label.new(attrs, children)
          when "Export"
            Layout::Dom::Export.new(attrs, children)
          else
            if custom_components[tag_name]?
              child = custom_components[tag_name].as(Layout::Dom::Element)
              child.attributes.merge!(attrs)
              child.children.concat(children)
              child.on_component_did_mount
              child
            else
              raise Exceptions::InvalidElementException.new(tag_name, @position)
            end
          end
        end
      end

      def parse_attr : Array(String)
        key = parse_bare_word
        skip_whitespace
        assert!(next_char == '=', @position)
        skip_whitespace
        value = parse_bare_or_quoted_value(key)
        [key, value]
      end

      def parse_function
        next_while do |char|
          char != '}'
        end
      end

      def parse_bare_value
        next_while do |char|
          char != '"'
        end
      end

      def parse_bare_or_quoted_value(key) : String
        possible_brace = peek
        if possible_brace == '{'
          next_char
          value = parse_function
          assert!(next_char == '}', @position)

          if [
               "onClick",
               "onChangeText",
               "onCut",
               "onPaste",
               "onCopy",
               "onComponentDidMount",
               "onComponentDidUpdate",
               "onComponentWillUnmount",
               "onValueChange",
               "onActivate",
             ].includes?(key)
            value
          else
            "#{Layout::Js::Engine::INSTANCE.evaluate(value)}"
          end
        elsif peek == '"'
          possible_quote = peek
          next_char
          value = parse_bare_value
          assert!(next_char == possible_quote, @position)
          value
        else
          parse_bare_word
        end
      end

      def parse_comment
        loop do
          skip_whitespace
          if peek == '-' && peek_again == '-' && peek_twice == '>'
            @position += 3
            break
          end
          next_char
        end
      end

      def parse_attributes : Hash(String, String)
        attrs = {} of String => String

        loop do
          skip_whitespace
          break if peek == '>' || peek == '/' && peek_again == '>'
          key, value = parse_attr
          attrs[key] = value
        end

        attrs
      end

      def assert!(truth : Bool, position : Int32)
        if !truth
          raise Exceptions::ParserException.new(position)
        end
      end

      def parse_nodes : Array(Layout::Dom::Node)
        nodes = [] of Layout::Dom::Node

        loop do
          skip_whitespace

          if eof? || is_closing_tag?
            break
          end

          if node = parse_node
            nodes.push(node)
          end
        end

        nodes
      end
    end
  end
end
