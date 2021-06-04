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

          context.eval! <<-JS
            function print(args) {
              __std__puts__(JSON.stringify(args));
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
