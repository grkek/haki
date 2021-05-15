require "./node"

module Layout
  module Dom
    class Element < Node
      include JSON::Serializable
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@kind, @attributes, @children = [] of Node)
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
      end

      def on_component_did_mount
        if class_id = @attributes["classId"]?
          Layout::Js::Engine::INSTANCE.evaluate("const #{class_id}State = #{self.to_json};")
        end

        if function = @attributes["onComponentDidMount"]?
          if class_id = @attributes["classId"]?
            Layout::Js::Engine::INSTANCE.evaluate("#{function}(#{class_id}State)")
          else
            Layout::Js::Engine::INSTANCE.evaluate("#{function}({})")
          end
        end
      end

      def on_component_did_update(class_id, event_type)
        if function = @attributes["onComponentDidUpdate"]?
          if class_id = @attributes["classId"]?
            Layout::Js::Engine::INSTANCE.evaluate("#{function}(#{class_id}State, \"#{class_id}\", \"#{event_type}\")")
          else
            Layout::Js::Engine::INSTANCE.evaluate("#{function}({}, \"#{class_id}\", \"#{event_type}\")")
          end
        end
      end

      def on_component_will_unmount
        if function = @attributes["onComponentWillUnmount"]?
          if class_id = @attributes["classId"]?
            Layout::Js::Engine::INSTANCE.evaluate("#{function}(#{class_id}State)")
          else
            Layout::Js::Engine::INSTANCE.evaluate("#{function}({})")
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
