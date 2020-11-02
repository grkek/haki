module Layout
  module Dom
    abstract class Node
      @kind : String
      @children : Array(Node)

      getter :kind, :children

      def initialize(@kind : String, @children : Array(Node))
      end
    end
  end
end
