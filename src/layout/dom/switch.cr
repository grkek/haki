require "./node"
require "./element"

module Layout
  module Dom
    class Switch < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes)
        @kind = "Switch"
        @children = [] of Node
        substitution()
      end

      def initialize_component(widget : Gtk::Widget, component_storage : Transpiler::ComponentStorage)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil

        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")
        value = to_bool(@attributes["value"]? || "false")

        switch = Gtk::Switch.new(name: id, halign: horizontal_align, valign: vertical_align, state: value)

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        value_change = @attributes["onValueChange"]? || nil

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        switch.on_state_set do
          if value_change
            Layout::Js::Engine::INSTANCE.evaluate("#{value_change}(getElementByComponentId(\"#{@cid}\"), #{switch.active})")
          end

          true
        end

        switch.on_event_after do |_widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            did_update(@cid, event.event_type.to_s)
            true
          end
        end

        containerize(widget, switch, box_expand, box_fill, box_padding)
        add_class_to_css(switch, class_name)
        component_storage.store(id, switch)
        component_storage.store(@cid, switch)
        did_mount(@cid)

        switch
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
