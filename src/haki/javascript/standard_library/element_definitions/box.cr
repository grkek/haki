module Haki
  module JavaScript
    module StandardLibrary
      module ElementDefinitions
        class Box < Definition
          property sandbox : Duktape::Sandbox

          def initialize(@sandbox : Duktape::Sandbox)
            @sandbox.eval_mutex! "std.element.box = {};"
          end

          def name : String
            "Box"
          end

          def definition_name : String
            "box"
          end

          def description : String
            "Box definition to provides functions to work with boxes."
          end

          def register_definitions
            @sandbox.push_global_proc("stdElementBoxCreate", 1) do |ptr|
              env = ::Duktape::Sandbox.new(ptr)

              begin
                pointer = ::Box(Gtk::Widget).unbox(env.require_pointer(0))
                element = Elements::Box.new({} of String => JSON::Any, [] of Elements::Node)

                widget = element.build_widget(pointer)

                env.push_string(widget.name)
                env.call_success
              rescue exception
                Log.error(exception: exception) { exception.message }

                LibDUK::Err::Error.to_i
              end
            end

            @sandbox.eval_mutex! <<-JS
              std.element.box.create = function(element) {
                id = stdElementBoxCreate(element);
                return globalThis[id];
              };
            JS
          end
        end
      end
    end
  end
end
