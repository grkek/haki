require "duktape/runtime"
require "../ext/**"
require "./std/**"

module Layout
  module Js
    class Engine
      include Std::Native
      include Std::Io
      include Std::Net

      INSTANCE = new

      property runtime : Duktape::Runtime
      property is_lazy : Bool = false

      delegate call, to: @runtime.context

      def initialize
        @runtime = Duktape::Runtime.new
        context = @runtime.context

        native()

        {% if flag?(:net) %}
          net()
        {% end %}

        {% if flag?(:io) %}
          io()
        {% end %}
      end

      def lazy_evaluate(js : String)
        is_lazy = true
        loop do
          if !is_lazy
            @runtime.eval(js)
            break
          end
        end
      end

      def evaluate(js : String)
        @runtime.eval(js)
      end
    end
  end
end
