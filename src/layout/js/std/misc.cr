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

          context.eval_string! <<-JS
            function print(args) {
              __std__puts__(JSON.stringify(args));
            }
          JS
        end
      end
    end
  end
end
