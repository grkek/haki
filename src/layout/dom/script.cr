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
                @attributes[key] = value.gsub(hash[0].not_nil!, "#{Layout::Js::Engine::INSTANCE.evaluate(hash[1].not_nil!)}")
              rescue ex : Exception
                @attributes[key] = value
                puts "An exception occured while evaluating a variable format routine: #{ex}"
              end
            end
          end
        end

        @children.each do |child|
          case child
          when Layout::Dom::Text
            begin
              Layout::Js::Engine::INSTANCE.evaluate(child.data.strip)
            rescue exception
              pp exception
              Layout::Js::Engine::INSTANCE.runtime.context.dump!
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
