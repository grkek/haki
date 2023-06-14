require "./node"
require "./generic"

module Haki
  module Elements
    class VerticalSeparator < Generic
      getter kind : String = "VerticalSeparator"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        separator = Haki::Attributes::Separator.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        widget = Gtk::Separator.new(name: separator.id, orientation: Gtk::Orientation::Vertical, halign: separator.horizontal_alignment, valign: separator.vertical_alignment)

        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, separator.class_name)

        widget
      end
    end
  end
end
