module Layout
  module Js
    module Std
      module Io
        macro io
          context.push_global_proc("fileRead", 1) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
  
            path = sbx.require_string 0
  
            File.open(path) do |fd|
              sbx.push_string(fd.gets_to_end)
            end
  
            sbx.call_success
          end

          context.push_global_proc("fileExists", 1) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
  
            path = sbx.require_string 0
  
            sbx.push_boolean File.exists?(path)
  
            sbx.call_success
          end

          context.push_global_proc("fileWrite", 2) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
  
            path = sbx.require_string 0
            content = sbx.require_string 1
  
            File.write(path, content)
  
            sbx.call_success
          end

          context.push_global_proc("puts", 1) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
            data = sbx.require_string 0
            puts data
            sbx.call_success
          end
        end
      end
    end
  end
end
