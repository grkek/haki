module Haki
  module Parser
    class Tokenizer
      include Elements

      enum Token
        DOCTYPE
        START_TAG
        END_TAG
        COMMENT
        CHARACTER
        EOF
      end

      property custom_components = {} of String => Node

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

      def next_while(&)
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

      def closing_tag?
        starts_with?("</")
      end

      def parse_node : Node?
        case peek
        when '<'
          parse_element
        else
          parse_text
        end
      end

      def parse_text : Node
        content = next_while { |c| c != '<' }
        Text.new(content)
      end

      # ameba:disable Metrics/CyclomaticComplexity
      def parse_element : Node?
        children = [] of Node

        assert!(next_char == '<', @position)

        if next_char == '!'
          assert!(next_char == '-', @position)
          assert!(next_char == '-', @position)

          return parse_comment
        end

        @position -= 1

        tag_name = parse_bare_word
        attributes = parse_attributes

        if next_char == '/'
          assert!(next_char == '>', @position)
          case tag_name
          when "Import"
            begin
              custom_components[attributes["as"].to_s] = Import.new(attributes)
            rescue exception
              case exception
              when Enumerable::EmptyError
                raise Exceptions::EmptyComponentException.new
              else
                raise exception
              end
            end

            nil
          when "Entry"
            Entry.new(attributes)
          when "Spinner"
            Spinner.new(attributes)
          when "ProgressBar"
            ProgressBar.new(attributes)
          when "Image"
            Image.new(attributes)
          when "VerticalSeparator"
            VerticalSeparator.new(attributes)
          when "HorizontalSeparator"
            HorizontalSeparator.new(attributes)
          when "Switch"
            Switch.new(attributes)
          else
            if child = custom_components[tag_name]?
              child = child.as(Generic)
              begin
                File.open(child.attributes["src"].to_s) do |fd|
                  document = fd.gets_to_end

                  if document.size < 1
                    raise Exceptions::EmptyComponentException.new
                  end

                  tokenizer = Parser::Tokenizer.new(document)
                  nodes = tokenizer.parse_nodes

                  element = nodes.first.as(Export)

                  if element.attributes["as"].to_s == child.attributes["as"].to_s
                    element
                  else
                    raise Exceptions::ImportNotFoundException.new(child.attributes["src"].to_s, child.attributes["as"].to_s, element.attributes["as"].to_s)
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
              raise Exceptions::InvalidComponentException.new(tag_name, @position)
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
            Script.new(attributes, children)
          when "StyleSheet"
            StyleSheet.new(attributes, children)
          when "Application"
            Application.new(attributes, children)
          when "Window"
            Window.new(attributes, children)
          when "Frame"
            Frame.new(attributes, children)
          when "Box"
            Box.new(attributes, children)
          when "ListBox"
            ListBox.new(attributes, children)
          when "ScrolledWindow"
            ScrolledWindow.new(attributes, children)
          when "Tab"
            Tab.new(attributes, children)
          when "EventBox"
            EventBox.new(attributes, children)
          when "Button"
            Button.new(attributes, children)
          when "Label"
            Label.new(attributes, children)
          when "TextView"
            TextView.new(attributes, children)
          when "Export"
            Export.new(attributes, children)
          else
            if custom_components[tag_name]?
              child = custom_components[tag_name].as(Generic)
              child.attributes.merge!(attributes)
              child.children.concat(children)
              child
            else
              raise Exceptions::InvalidComponentException.new(tag_name, @position)
            end
          end
        end
      end

      def parse_attribute : Tuple(String, JSON::Any)
        key = parse_bare_word
        skip_whitespace
        assert!(next_char == '=', @position)
        skip_whitespace
        value = parse_bare_or_quoted_value(key)
        {key, value}
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

      def parse_bare_or_quoted_value(key) : JSON::Any
        if peek == '"'
          possible_quote = peek
          next_char
          value = parse_bare_value
          assert!(next_char == possible_quote, @position)

          JSON::Any.new(value)
        else
          value = parse_bare_word

          JSON.parse(value)
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

      def parse_attributes : Hash(String, JSON::Any)
        attributes = {} of String => JSON::Any

        loop do
          skip_whitespace
          break if peek == '>' || peek == '/' && peek_again == '>'
          key, value = parse_attribute
          attributes[key] = value
        end

        attributes
      end

      def assert!(truth : Bool, position : Int32)
        if !truth
          raise Exceptions::ParserException.new(position)
        end
      end

      def parse_nodes : Array(Node)
        nodes = [] of Node

        loop do
          skip_whitespace

          if eof? || closing_tag?
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
