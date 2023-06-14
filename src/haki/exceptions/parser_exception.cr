module Haki
  module Exceptions
    class ParserException < Exception
      def initialize(position : Int32)
        super("Failed to parse a character at `#{position.colorize(:white)}`!")
      end
    end
  end
end
