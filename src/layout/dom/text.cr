require "./node"

module Layout
  module Dom
    class Text < Node
      getter :data

      def initialize(@data : String)
        @kind = "Text"
        @children = [] of Node
      end

      def to_html : String
        data
      end
    end
  end
end
