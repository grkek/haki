require "./node"

module Haki
  module Elements
    class Text < Node
      getter kind : String = "Text"
      getter children : Array(Node) = [] of Node
      getter content : String = ""

      def initialize(content : String = "")
        matches = content.scan(/\${(.*?)}/)

        case matches.size
        when 0
          @content = content
        else
          # matches.each do |match|
          #   hash = match.to_h

          #   begin
          #     # TODO: Refactor and use the new engine.
          #     @content = content.gsub(hash[0].not_nil!, Duktape::Engine.instance.eval!("__std__value_of__(#{hash[1].not_nil!})").to_s)
          #   rescue ex : Exception
          #     @content = content
          #     raise Exceptions::RuntimeException.new("An exception occured while evaluating a variable format routine: #{ex}")
          #   end
          # end
        end
      end
    end
  end
end
