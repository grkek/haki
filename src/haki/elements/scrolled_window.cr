require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class ScrolledWindow < Haki::Attributes::Base
      end
    end

    class ScrolledWindow < Generic
      getter kind : String = "ScrolledWindow"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        scrolled_window = Attributes::ScrolledWindow.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        widget = Gtk::ScrolledWindow.new(name: scrolled_window.id, halign: scrolled_window.horizontal_alignment, valign: scrolled_window.vertical_alignment)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, scrolled_window.class_name)

        register_component(widget, scrolled_window.class_name, @kind)
        widget
      end
    end
  end
end
