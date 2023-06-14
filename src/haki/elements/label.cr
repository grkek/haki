require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class Label < Haki::Attributes::Base
      end
    end

    class Label < Generic
      getter kind : String = "Label"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        label = Attributes::Label.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)
        text = children.first.as(Text).content.to_s if children.size != 0

        widget = Gtk::Label.new(name: label.id, label: text, halign: label.horizontal_alignment, valign: label.vertical_alignment, wrap: true)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, label.class_name)

        register_component(widget, label.class_name, @kind)
        widget
      end
    end
  end
end
