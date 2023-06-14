require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class Box < Haki::Attributes::Base
        include JSON::Serializable

        @[JSON::Field(key: "spacing")]
        property spacing : Int32 = 2
      end
    end

    class Box < Generic
      getter kind : String = "Box"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        box = Attributes::Box.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        widget = Gtk::Box.new(name: box.id, orientation: box.orientation, spacing: box.spacing, halign: box.horizontal_alignment, valign: box.vertical_alignment)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, box.class_name)

        register_component(widget, box.class_name, @kind)

        widget
      end
    end
  end
end
