module Haki
  module JavaScript
    module StandardLibrary
      abstract class Module
        abstract def name : String
        abstract def description : String

        abstract def module_name : String
        abstract def definitions : Array(Definition)
      end
    end
  end
end
