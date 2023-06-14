module Haki
  module Exceptions
    class InvalidComponentException < Exception
      def initialize(tag_name : String, position : Int32)
        tag_names = {{ Elements.constants.map(&.stringify) }}
        match = Levenshtein.find(tag_name, tag_names)

        case match
        when String
          super("Component `#{tag_name.colorize(:light_yellow)}` defined at `#{position.colorize(:white)}` is not valid, maybe you wanted to define the tag as: `#{match.colorize(:light_green)}` instead?")
        when Nil
          super("Component `#{tag_name.colorize(:light_yellow)}` defined at `#{position.colorize(:white)}` is not valid.")
        end
      end
    end
  end
end
