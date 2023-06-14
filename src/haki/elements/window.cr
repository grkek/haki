require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class Window < Haki::Attributes::Base
        include JSON::Serializable

        @[JSON::Field(key: "title")]
        property title : String = "Untitled"

        @[JSON::Field(key: "width")]
        property width : Int32 = 800

        @[JSON::Field(key: "height")]
        property height : Int32 = 600
      end
    end

    class Window < Generic
      getter kind : String = "Window"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      # Edge case for the application, since the Gtk::Application is not fully
      # Gtk::Widget compliant.
      def build_widget(parent : Gtk::Application) : Gtk::Widget
        window = Attributes::Window.from_json(attributes.to_json)

        widget = Gtk::ApplicationWindow.new(name: window.id, application: parent, title: window.title, default_width: window.width, default_height: window.height)

        widget.destroy_signal.connect(->exit)

        register_events(widget)
        add_class_to_css(widget, window.class_name)

        register_component(widget, window.class_name, @kind)
        widget
      end
    end
  end
end
