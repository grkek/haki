module Haki
  module JavaScript
    module StandardLibrary
      module ElementDefinitions
        class Label < Definition
          property sandbox : Duktape::Sandbox

          def initialize(@sandbox : Duktape::Sandbox)
            @sandbox.eval_mutex! "std.element.label = {};"
          end

          def name : String
            "Label"
          end

          def definition_name : String
            "label"
          end

          def description : String
            "Label definition to provides functions to work with labels."
          end

          def register_definitions
            @sandbox.push_global_proc("stdElementLabelCreate", 1) do |ptr|
              env = ::Duktape::Sandbox.new(ptr)

              begin
                pointer = ::Box(Gtk::Widget).unbox(env.require_pointer(0))
                element = Elements::Label.new({} of String => JSON::Any, [] of Elements::Node)

                widget = element.build_widget(pointer)

                env.push_string(widget.name)
                env.call_success
              rescue exception
                Log.error(exception: exception) { exception.message }

                LibDUK::Err::Error.to_i
              end
            end

            @sandbox.eval_mutex! <<-JS
              std.element.label.create = function(element) {
                id = stdElementLabelCreate(element);
                return globalThis[id];
              };
            JS
          end
        end
      end
    end
  end
end
