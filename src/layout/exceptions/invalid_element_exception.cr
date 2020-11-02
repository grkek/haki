module Layout
  module Exceptions
    class InvalidElementException < Exception
      def initialize(tag_name : String, position : Int32)
        super("Element `\033[1;33m#{tag_name}\033[0m` defined at `\033[1;37m#{position}\033[0m` is not valid!")
      end
    end
  end
end
