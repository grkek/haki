module Haki
  module Exceptions
    class ComponentNotFoundException < Exception
      def initialize(cid)
        super("Component #{cid} was not found!")
      end
    end
  end
end
