module Haki
  module Exceptions
    class RuntimeException < Exception
      def initialize(message : String)
        super(message)
      end
    end
  end
end
