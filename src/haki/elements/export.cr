require "./node"
require "./generic"

module Haki
  module Elements
    class Export < Generic
      getter kind : String = "Export"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end
    end
  end
end
