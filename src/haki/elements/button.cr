require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class Button < Haki::Attributes::Base
        include JSON::Serializable

        @[JSON::Field(key: "hasFrame")]
        property? has_frame : Bool = false
      end
    end

    class Button < Generic
      getter kind : String = "Button"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        button = Attributes::Button.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        text = children.first.as(Text).content.to_s if children.size != 0
        widget = Gtk::Button.new(name: button.id, label: text, has_frame: button.has_frame?, halign: button.horizontal_alignment, valign: button.vertical_alignment)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, button.class_name)

        register_component(widget, button.class_name, @kind)

        widget
      end
    end
  end
end
