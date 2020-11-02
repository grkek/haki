require "./layout/**"

module Layout; end

# require "duktape/runtime"

# module Duktape
#   module API
#     module Push
#       def push_custom_proc(nargs : Int32 = 0, &block : LibDUK::Context -> Int32)
#         LibDUK.push_pointer(ctx, Box.box(block))
#         pp ctx
#         LibDUK.push_c_function(ctx, ->(ctx) {
#           pointer = LibDUK.get_pointer(ctx, 0)
#           Box(typeof(block)).unbox(pointer).call(ctx)
#         }, nargs)
#       end

#       def push_custom_global_proc(name : String, nargs : Int32 = 0, &block : LibDUK::Context -> Int32)
#         push_global_object
#         push_custom_proc nargs, &block
#         put_prop_string -3, name
#         pop
#       end
#     end
#   end

#   class Runtime
#     property context : Duktape::Sandbox | Duktape::Context
#   end
# end


# class Example
#   def initialize(a, b)
    
#   end
# end


# runtime = Duktape::Runtime.new
# collection = [] of String

# exam = Example.new("a", "b")

# runtime.context.push_custom_global_proc("resizeWindow", 2) do |ptr|
#   sbx = Duktape::Sandbox.new(ptr)
#   a = sbx.require_int 0
#   b = sbx.require_int 1

#   sbx.call_success
# end

# runtime.context.dump!

# runtime.eval("resizeWindow(1, 2)")