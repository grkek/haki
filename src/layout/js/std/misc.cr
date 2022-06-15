module Layout
  module Js
    module Std
      module Misc
        macro misc
          context.push_global_proc("__std__puts__", 1) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
            args = sbx.require_string 0
            puts args
            sbx.call_success
          end

          use_proc = ->(path : String) {
            context.eval File.read(path)
          }

          context.push_heap_stash
          context.push_pointer(::Box.box(use_proc))
          context.put_prop_string(-2, "__std__use__")

          context.push_global_proc("__std__use__", 1) do |ptr|
            env = Duktape::Sandbox.new(ptr)
            env.push_heap_stash
            env.get_prop_string(-1, "__std__use__")
            proc = ::Box(Proc(String, String)).unbox(env.get_pointer(-1))
            path = env.get_string(0).not_nil!
            pointer = proc.call(path)

            env.call_success
          end

          context.eval! <<-JS
            function print(args) {
              __std__puts__(JSON.stringify(args));
            }

            function use(arg) {
              __std__use__(arg)
            }

            function __std__value_of__(value) {
              return value;
            }
          JS
        end
      end
    end
  end
end
