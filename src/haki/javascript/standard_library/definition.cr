module Haki
  module JavaScript
    module StandardLibrary
      abstract class Definition
        abstract def name : String
        abstract def description : String

        abstract def definition_name : String
        abstract def register_definitions
      end
    end
  end
end
