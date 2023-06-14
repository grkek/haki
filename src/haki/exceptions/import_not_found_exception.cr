module Haki
  module Exceptions
    class ImportNotFoundException < Exception
      def initialize(from : String, _as : String, suggestion : String)
        super("Element imported from `#{from}` as `#{_as}` is not valid, make sure you export the component and match the exported name!\n\n  Maybe you wanted to import the component as: `#{suggestion.colorize(:light_green)}`?\n\n")
      end
    end
  end
end
