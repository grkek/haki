module Haki
  module Exceptions
    class ParserException < Exception
      def initialize(position : Int32)
        super("Failed to parse a character at `\033[1;37m#{position}\033[0m`!")
      end
    end
  end
end
