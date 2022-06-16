module Haki
  module Duktape
    module Std
      module Process
        macro process
          context.push_global_proc("__std__exit__", 1) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)
            exit_code = sbx.require_int 0
            exit(exit_code)
            sbx.call_success
          end

          context.eval! <<-JS
            const process = {
              exit : function (exitCode) {
                __std__exit__(exitCode);
              },
            };
          JS
        end
      end
    end
  end
end
