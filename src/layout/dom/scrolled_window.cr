require "./node"
require "./element"

module Layout
  module Dom
    class ScrolledWindow < Element
      property attributes : Hash(String, String)

      def initialize(@attributes, @children)
        @kind = "ScrolledWindow"
        substitution()
      end

      def initialize_component(widget : Gtk::Widget, component_storage : Transpiler::ComponentStorage)
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

        spacing = @attributes["spacing"]? || "2"

        scrolled_window = Gtk::ScrolledWindow.new(name: id, halign: horizontal_align, valign: vertical_align)

        scrolled_window.on_event_after do |widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            did_update(@cid, event.event_type.to_s)
            true
          end
        end

        containerize(widget, scrolled_window, box_expand, box_fill, box_padding)

        add_class_to_css(scrolled_window, class_name)
        component_storage.store(id, scrolled_window)
        component_storage.store(@cid, scrolled_window)
        did_mount(@cid)

        scrolled_window
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
