module Layout
  module Js
    module Std
      module System
        macro system
          context.push_global_proc("__std__cpu_count__", 0) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
            sbx.push_int(System.cpu_count())
            sbx.call_success
          end

          context.push_global_proc("__std__hostname__", 0) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
            sbx.push_string(System.hostname())
            sbx.call_success
          end

          context.eval_string! <<-JS
            const system = {
              getCpuCount : function () {
                return __std__cpu_count__();
              },
              getHostname : function () {
                return __std__hostname__();
              }
            };
          JS
        end
      end
    end
  end
end
