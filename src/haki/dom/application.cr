require "./node"
require "./element"

module Haki
  module Dom
    class Application < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes, @children)
        @kind = "Application"
        substitution()
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
