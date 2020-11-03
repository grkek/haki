require "http/client"

module Layout
  module Js
    module Std
      module Net
        macro net
          context.push_global_proc("httpGet", 3) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)

  
            sbx.call_success
          end
        end
      end
    end
  end
end
