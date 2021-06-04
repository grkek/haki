module Duktape
  module API::Debug
    def dump!
      puts("STACK: #{stack}")
    end
  end
end
