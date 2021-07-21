require "duktape/runtime"
require "../ext/**"
require "./std/**"

module Layout
  module Js
    class Engine
      include Std::Process
      include Std::FileSystem
      include Std::Net
      include Std::Gtk
      include Std::Misc
      include Std::System

      INSTANCE = new

      property runtime : Duktape::Runtime
      property is_lazy : Bool = false

      delegate call, to: @runtime.context

      def initialize
        @runtime = Duktape::Runtime.new
        context = @runtime.context

        misc()
        process()
        gtk()
        net()
        fs()
        system()

        context.eval! <<-JS
          String.prototype.format = function() {
              var formatted = this;
              for( var arg in arguments ) {
                  formatted = formatted.replace("{" + arg + "}", arguments[arg]);
              }
              return formatted;
          };
        JS
      end

      def evaluate(js : String)
        begin
          return_value = @runtime.eval(js)
          return_value
        rescue exception
          puts "Execution failed during:"
          puts "\033[0;33m#{Beautify.js(js)}\033[0m"

          puts "Exception:"
          puts exception
        end
      end
    end
  end
end
