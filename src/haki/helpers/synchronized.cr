module Haki
  module Helpers
    class Synchronized(T)
      Log = ::Log.for(self)

      def initialize(*args)
        @value = T.new(*args)
        @mutex = Mutex.new(:reentrant)
      end

      macro method_missing(call)
        @mutex.synchronize do
          @value.{{call}}
        end
      end
    end
  end
end
