require "http/client"

module Haki
  module Duktape
    module Std
      module Net
        macro net
          context.push_global_proc("__std__http_request__", 3) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)
            method = sbx.require_string 0
            path = sbx.require_string 1
            params = sbx.require_object 2

            response = HTTP::Client.exec(method, path)
            sbx.push_string response.body

            sbx.call_success
          end

          context.eval! <<-JS
            const http = {
              get: function(path, params) { return __std__http_request__("GET", path, params); },
              post: function(path, params) { return __std__http_request__("POST", path, params); }
            };
          JS
        end
      end
    end
  end
end
