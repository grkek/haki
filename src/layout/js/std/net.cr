require "http/client"

module Layout
  module Js
    module Std
      module Net
        macro net
          context.push_global_proc("httpGet", 3) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)

            # WIP

            # address = sbx.require_string 0

            # headers = ""
            # body = sbx.require_string 2

            # response = HTTP::Client.get(
            #   url: address,
            #   headers: headers,
            #   body: body
            # )

            # idx = sbx.push_object
            # sbx.push_int response.status_code
            # sbx.put_prop_string idx, "statusCode"
  
            sbx.call_success
          end
        end
      end
    end
  end
end
