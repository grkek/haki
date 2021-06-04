require "./node"
require "./element"

module Layout
  module Dom
    class Tab < Element
      property attributes : Hash(String, String)

      def initialize(@attributes, @children)
        @kind = "Tab"
        substitution()
      end

      def initialize_component(widget : Gtk::Widget, component_storage : Transpiler::ComponentStorage)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        tab = Gtk::Notebook.new(name: id, halign: horizontal_align, valign: vertical_align)

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        containerize(widget, tab, box_expand, box_fill, box_padding)

        tab.on_event_after do |widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            did_update(@cid, event.event_type.to_s)
            true
          end
        end

        add_class_to_css(tab, class_name)
        component_storage.store(id, tab)
        component_storage.store(@cid, tab)
        did_mount(@cid)

        tab
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
