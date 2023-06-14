module Haki
  module JavaScript
    class Engine
      @@instance = new

      mutex : Mutex
      server : UNIXServer

      getter sandbox : Duktape::Sandbox
      getter path : String = "/tmp/#{UUID.random}"

      def self.instance
        @@instance
      end

      def initialize
        @sandbox = Duktape::Sandbox.new

        @mutex = Mutex.new(:reentrant)
        @server = UNIXServer.new(path)

        # Evaluate CoreJS source code for a modern JavaScript interface.
        @sandbox.eval_mutex! Storage.get("core.js").gets_to_end

        # Evaluate Babel source code for a modern JavaScript interface.
        @sandbox.eval_mutex! Storage.get("babel.js").gets_to_end

        # Create a global variable for the standard library.
        @sandbox.eval_mutex! "const std = {};"

        # Initialize the standard library for JavaScript.
        modules = [StandardLibrary::Element, StandardLibrary::Minuscule]

        modules.each do |library_module|
          instance = library_module.new(@sandbox)

          instance.definitions.each do |definition|
            begin
              definition.register_definitions
            rescue exception
              Log.error(exception: exception) { "Failed to register #{instance.name} module" }
            end
          end
        end

        sandbox.eval!("const exports = {};")

        # TODO: Re-work the require function to have a better way of module identification.
        sandbox.eval! <<-JS
            const require = function(filePath) {
              var fullPath = filePath + ".js"

              if(fs.fileExists(fullPath)) {
                var sourceCode = fs.readFile(fullPath)
                eval(Babel.transform(sourceCode, {presets: ['es2015']}).code)

                return exports.default;
              } else {
                throw "File doesn't exist, " + fullPath
              }
            }
          JS

        # Handle incomming connections to the socket.
        spawn do
          loop do
            if client = @server.accept?
              spawn handle_client(client)
            end
          end
        end
      end

      private def handle_client(client : UNIXSocket)
        loop do
          request = Message::Request.from_json(client.gets || raise "Empty message provided to the JavaScript engine")

          @mutex.synchronize do
            if request.processing == Message::Processing::EVENT
              Registry.instance.refresh_state(request.id)
            end

            if source_code = request.source_code
              begin
                Log.debug { "Evaluating code from #{request.id}, #{request.file}:#{request.line}, #{request.source_code}" }

                eval! source_code
              rescue exception
                Log.debug(exception: exception) { exception.message }
              end
            end
          end
        end
      end

      private def eval!(source_code : String, preset : String = "es2015")
        @sandbox.eval_mutex! JSON.parse(@sandbox.call("Babel.transform", source_code, {presets: ["#{preset}"]}).to_json)["code"].to_s
      end
    end
  end
end
