require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class Frame < Haki::Attributes::Base
        include JSON::Serializable

        @[JSON::Field(key: "text")]
        property text : String?
      end
    end

    class Frame < Generic
      getter kind : String = "Frame"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        frame = Attributes::Frame.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        widget = Gtk::Frame.new(name: frame.id, label: frame.text, halign: frame.horizontal_alignment, valign: frame.vertical_alignment)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, frame.class_name)

        register_component(widget, frame.class_name, @kind)
        widget
      end
    end
  end
end
