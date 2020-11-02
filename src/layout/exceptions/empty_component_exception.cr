module Layout
  module Exceptions
    class EmptyComponentException < Exception
      def initialize
        super("You are parsing an empty file, please make sure you supply some content!")
      end
    end
  end
end
