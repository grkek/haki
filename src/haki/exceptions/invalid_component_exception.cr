require "levenshtein"

module Haki
  module Exceptions
    class InvalidComponentException < Exception
      def initialize(tag_name : String, position : Int32)
        tag_names = {{ Dom.constants.map(&.stringify) }}
        match = Levenshtein.find(tag_name, tag_names)

        case match
        when String
          super("Component `\033[1;33m#{tag_name}\033[0m` defined at `\033[1;37m#{position}\033[0m` is not valid!\n\n  Maybe you wanted to define the tag as: `\033[0;32m#{match}\033[0m` instead?\n\n")
        when Nil
          super("Component `\033[1;33m#{tag_name}\033[0m` defined at `\033[1;37m#{position}\033[0m` is not valid!")
        end
      end
    end
  end
end
