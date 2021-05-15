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
        # ameba:disable Lint/UselessAssign
        context = @runtime.context

        misc()
        process()
        gtk()
        net()
        fs()
        system()

        context.eval_string! <<-JS
          String.prototype.format = function() {
              var formatted = this;
              for( var arg in arguments ) {
                  formatted = formatted.replace("{" + arg + "}", arguments[arg]);
              }
              return formatted;
          };
        JS
      end

      def lazy_evaluate(js : String)
        is_lazy = true
        loop do
          if !is_lazy
            @runtime.context.eval(js)
            break
          end
        end
      end

      def evaluate(js : String)
        @runtime.context.eval(js)
      end
    end
  end
end
