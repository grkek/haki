require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class Tab < Haki::Attributes::Base
      end
    end

    class Tab < Generic
      getter kind : String = "Tab"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        tab = Attributes::Tab.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        widget = Gtk::Notebook.new(name: tab.id, halign: tab.horizontal_alignment, valign: tab.vertical_alignment)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, tab.class_name)

        register_component(widget, tab.class_name, @kind)
        widget
      end
    end
  end
end
