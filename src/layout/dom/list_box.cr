require "./node"
require "./element"

module Layout
  module Dom
    class ListBox < Element
      property attributes : Hash(String, String)

      def initialize(@attributes, @children)
        @kind = "ListBox"
        substitution()
      end

      def initialize_component(widget : Gtk::Widget)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        list_box = Gtk::ListBox.new(name: id, halign: horizontal_align, valign: vertical_align)

        list_box.on_event_after do |_widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            # TODO: Add an event handler for the components to forward information to JavaScript.
            true
          end
        end

        containerize(widget, list_box, box_expand, box_fill, box_padding)
        add_class_to_css(list_box, class_name)

        list_box
      end

      def to_html : String
        attrs = attributes.map do |key, value|
          "#{key}='#{value}'"
        end

        children_html = children.map(&.to_html.as(String)).join("")
        "<#{kind} #{attrs.join(' ')}>#{children_html}</#{kind}>"
      end
    end
  end
end
