require "./node"
require "./generic"

module Haki
  module Elements
    module Attributes
      class TextView < Haki::Attributes::Base
      end
    end

    class TextView < Generic
      getter kind : String = "TextView"
      getter attributes : Hash(String, JSON::Any)

      def initialize(@attributes, @children = [] of Node)
        super(@kind, @attributes, @children)
      end

      def build_widget(parent : Gtk::Widget) : Gtk::Widget
        text_view = Attributes::TextView.from_json(attributes.to_json)
        container_attributes = Haki::Attributes::Container.from_json(attributes.to_json)

        text = @children[0].as(Text).content.to_s

        widget = Gtk::TextView.new(name: text_view.id, halign: text_view.horizontal_alignment, valign: text_view.vertical_alignment)
        widget.buffer.set_text(text, text.size)

        register_events(widget)
        containerize(parent, widget, container_attributes)
        add_class_to_css(widget, class_name)

        register_component(widget, class_name, @kind)
        widget
      end
    end
  end
end
