require "./node"
require "./element"

module Layout
  module Dom
    class Script < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes, @children)
        @kind = "Script"

        @attributes.map do |key, value|
          matches = value.scan(/\${(.*?)}/)

          case matches.size
          when 0
            @attributes[key] = value
          else
            matches.each do |match|
              hash = match.to_h

              begin
                @attributes[key] = value.gsub(hash[0].not_nil!, Layout::Js::Engine::INSTANCE.evaluate("__std__value_of__(#{hash[1].not_nil!})").to_s)
              rescue ex : Exception
                @attributes[key] = value
                puts "An exception occured while evaluating a variable format routine: #{ex}"
              end
            end
          end
        end

        if source_file = @attributes["src"]?
          fp = File.open(source_file).gets_to_end
          Layout::Js::Engine::INSTANCE.evaluate(fp)

          if @children.size != 0
            @children.each do |child|
              case child
              when Layout::Dom::Text
                begin
                  Layout::Js::Engine::INSTANCE.evaluate(child.data)
                rescue exception
                  pp exception
                  Layout::Js::Engine::INSTANCE.runtime.context.dump!
                end
              end
            end
          end
        else
          @children.each do |child|
            case child
            when Layout::Dom::Text
              begin
                Layout::Js::Engine::INSTANCE.evaluate(child.data)
              rescue exception
                pp exception
                Layout::Js::Engine::INSTANCE.runtime.context.dump!
              end
            end
          end
        end
      end

      def to_html : String
        attrs = attributes.map do |key, value|
          "#{key}='#{value}'"
        end

        children_html = children.map(&.to_html.as(String)).join("")
        "<#{kind} #{attrs.join(' ')}>#{children_html}</#{kind}>"
      end
    end
  end
end
