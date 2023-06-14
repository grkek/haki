module Haki
  module JavaScript
    module StandardLibrary
      module ElementDefinitions
        class Button < Definition
          property sandbox : Duktape::Sandbox

          def initialize(@sandbox : Duktape::Sandbox)
            @sandbox.eval_mutex! "std.element.button = {};"
          end

          def name : String
            "Button"
          end

          def definition_name : String
            "button"
          end

          def description : String
            "Button definition to provides functions to work with buttons."
          end

          def register_definitions
            @sandbox.push_global_proc("stdElementButtonCreateLabel", 2) do |ptr|
              env = ::Duktape::Sandbox.new(ptr)

              begin
                pointer = ::Box(Gtk::Widget).unbox(env.require_pointer(0))
                label = env.require_string(1)

                element = Elements::Button.new({} of String => JSON::Any, [Elements::Text.new(label)] of Elements::Node)

                widget = element.build_widget(pointer)

                env.push_string(widget.name)
                env.call_success
              rescue exception
                Log.error(exception: exception) { exception.message }

                LibDUK::Err::Error.to_i
              end
            end

            @sandbox.push_global_proc("stdElementButtonCreate", 1) do |ptr|
              env = ::Duktape::Sandbox.new(ptr)

              begin
                pointer = ::Box(Gtk::Widget).unbox(env.require_pointer(0))
                element = Elements::Button.new({} of String => JSON::Any, [] of Elements::Node)

                widget = element.build_widget(pointer)

                env.push_string(widget.name)
                env.call_success
              rescue exception
                Log.error(exception: exception) { exception.message }

                LibDUK::Err::Error.to_i
              end
            end

            @sandbox.eval_mutex! <<-JS
              std.element.button.create = function(element) {
                id = stdElementButtonCreate(element);
                return globalThis[id];
              };

              std.element.button.createLabel = function(element, label) {
                id = stdElementButtonCreateLabel(element, label);
                return globalThis[id];
              };
            JS
          end
        end
      end
    end
  end
end
