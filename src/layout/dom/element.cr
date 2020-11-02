require "./node"

module Layout
  module Dom
    class Element < Node
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@kind, @attributes, @children = [] of Node)
      end

      def on_component_did_mount
        if function = @attributes["onComponentDidMount"]?
          Layout::Js::Engine::INSTANCE.evaluate(function)
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
