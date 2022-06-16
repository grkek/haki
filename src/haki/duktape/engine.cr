require "duktape/runtime"
require "../ext/**"
require "./std/**"

module Haki
  module Duktape
    class Engine
      include Std::Process
      include Std::FileSystem
      include Std::Net
      include Std::Gtk
      include Std::Misc
      include Std::System

      property runtime : ::Duktape::Runtime
      property is_lazy : Bool = false

      delegate call, to: @runtime.context

      @@instance = new

      def self.instance
        @@instance
      end

      def initialize
        @runtime = ::Duktape::Runtime.new
        context = @runtime.context

        misc()
        process()
        gtk()
        net()
        fs()
        system()

        eval! <<-JS
          String.prototype.format = function() {
              var formatted = this;
              for( var arg in arguments ) {
                  formatted = formatted.replace("{" + arg + "}", arguments[arg]);
              }
              return formatted;
          };
        JS
      end

      def eval!(source : String)
        @runtime.context.eval! source
      rescue exception
        pp exception
      end
    end
  end
end
