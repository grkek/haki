module Haki
  module Duktape
    module Std
      module FileSystem
        macro fs
          context.push_global_proc("__std__read_file__", 1) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)

            path = sbx.require_string 0

            File.open(path) do |fd|
              sbx.push_string(fd.gets_to_end)
            end

            sbx.call_success
          end

          context.push_global_proc("__std__file_exists__", 1) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)

            path = sbx.require_string 0

            sbx.push_boolean File.exists?(path)

            sbx.call_success
          end

          context.push_global_proc("__std__write_file__", 2) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)

            path = sbx.require_string 0
            content = sbx.require_string 1

            File.write(path, content)

            sbx.call_success
          end

          context.eval! <<-JS
            const fs = {
              readFile : function (filePath) {
                return __std__read_file__(filePath);
              },
              writeFile : function (filePath, fileContent) {
                if(__std__write_file__(filePath, fileContent)){
                  return true;
                } else {
                  return false;
                }
              },
              fileExists : function (filePath) {
                return __std__file_exists__(filePath);
              }
            };
          JS
        end
      end
    end
  end
end
