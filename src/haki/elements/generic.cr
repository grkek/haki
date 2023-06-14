require "./node"

module Haki
  module Elements
    class Generic < Node
      include JSON::Serializable

      alias Engine = JavaScript::Engine

      getter kind : String
      getter attributes : Hash(String, JSON::Any)

      @socket : UNIXSocket

      def initialize(@kind, @attributes, @children = [] of Node)
        @socket = UNIXSocket.new(JavaScript::Engine.instance.path)
        attributes.merge!({"id" => JSON::Any.new(Helpers::Randomizer.random_string)}) unless attributes["id"]?
      end

      private def register_events(widget : Gtk::Widget)
        event_controller = Gtk::EventControllerLegacy.new

        event_controller.event_signal.connect(after: true) do |event|
          case event.event_type
          when Gdk::EventType::KeyPress, Gdk::EventType::KeyRelease
          else
            event_name = event.event_type.to_s.camelcase(lower: true)

            case event_name
            when "buttonPress"
              handle_event(widget.name, "onPress", nil)
            when "buttonRelease"
              handle_event(widget.name, "onRelease", nil)
            else
              handle_event(widget.name, event_name, nil)
            end
          end

          false
        end

        widget.add_controller(event_controller)

        event_controller = Gtk::EventControllerKey.new
        event_controller.key_pressed_signal.connect(->(key_value : UInt32, _key_code : UInt32, _modifier_type : Gdk::ModifierType) {
          handle_event(widget.name, "onKeyPress", key_value)

          true
        })

        widget.add_controller(event_controller)
      end

      private def register_component(widget : Gtk::Widget, class_name : String, kind : String)
        Registry.instance.register(Component.new(id: widget.name, class_name: class_name, kind: kind, widget: widget))
        Registry.instance.refresh_state(widget.name)
      end

      private def handle_event(id : String, event_name : String, arguments)
        if arguments
          source_code = [id, ".", "properties", ".", event_name, "(", arguments.to_json, ")"].join
        else
          source_code = [id, ".", "properties", ".", event_name, "()"].join unless arguments
        end

        request = JavaScript::Message::Request.new(
          id: id,
          directory: __DIR__,
          file: __FILE__,
          line: __LINE__,
          processing: JavaScript::Message::Processing::EVENT,
          event_name: event_name,
          source_code: source_code)

        @socket.puts(request.to_json)
      end

      private def add_class_to_css(widget, class_name)
        if class_name
          context = widget.style_context
          context.add_class(class_name)
        end
      end

      private def containerize(parent, component, container_attributes)
        case parent
        when Gtk::Notebook
          if container_attributes.container_label
            parent.append_page(component, Gtk::Label.new(label: container_attributes.container_label))
          else
            parent.append_page(component, nil)
          end
        when Gtk::Box
          component.hexpand = container_attributes.expand?
          component.vexpand = container_attributes.expand?

          margin = container_attributes.padding
          component.margin_top = margin
          component.margin_bottom = margin
          component.margin_start = margin
          component.margin_end = margin

          parent.append(component)
        when Gtk::ScrolledWindow, Gtk::Frame
          parent.child = component
        when Gtk::ListBox
          parent.insert(component, 1_000_000)
        when Gtk::ApplicationWindow
          parent.child = component
        end
      end
    end
  end
end
