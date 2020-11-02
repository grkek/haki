module Layout
  module Js
    module Std
      module Native
        macro native
          context.push_global_proc("exit", 1) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
            exit_code = sbx.require_int 0
            exit(exit_code)
  
            sbx.call_success
          end
        end
      end
    end
  end
end
