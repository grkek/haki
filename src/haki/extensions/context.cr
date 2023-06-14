class Object
  macro methods
    {{ @type.methods.map &.name.stringify }}
  end
end

module Duktape
  class Context
    @mutex = Mutex.new(:reentrant)
  end
end
