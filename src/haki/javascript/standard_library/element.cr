require "./module"

module Haki
  module JavaScript
    module StandardLibrary
      class Element < Module
        property sandbox : Duktape::Sandbox

        def initialize(@sandbox : Duktape::Sandbox)
          @sandbox.eval_mutex! "std.element = {};"
        end

        def name : String
          "Element"
        end

        def module_name : String
          "element"
        end

        def description : String
          "Element module allows the user to create GUI components."
        end

        def definitions : Array(Definition)
          @sandbox.push_global_proc("stdElementGetElementById", 1) do |ptr|
            env = ::Duktape::Sandbox.new(ptr)

            begin
              id = env.require_string(0)
              component = Registry.instance.registered_components[id]

              env.push_pointer(::Box.box(component.widget))

              env.call_success
            rescue exception
              Log.error(exception: exception) { exception.message }

              LibDUK::Err::Error.to_i
            end
          end

          @sandbox.eval_mutex! "std.element.getElementById = function(id) { return stdElementGetElementById(id); };"

          [ElementDefinitions::Box.new(@sandbox), ElementDefinitions::Button.new(@sandbox), ElementDefinitions::Label.new(@sandbox)] of Definition
        end
      end
    end
  end
end
