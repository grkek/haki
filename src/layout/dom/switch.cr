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

      def initialize_component(widget : Gtk::Widget)
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

        Js::Engine.instance.eval! ["const", id, "=", {type: "Switch", className: class_name, availableCallbacks: ["onStateSet", "onEvent"]}.to_json].join(" ")

        switch.on_state_set do
          Js::Engine.instance.eval! [id, ".", "onStateSet", "(", switch.active, ")"].join

          true
        end

        switch.on_event_after do |_widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            Js::Engine.instance.eval! [id, ".", "onEvent", "(", "\"", event.event_type.to_s, "\"", ")"].join
            true
          end
        end

        containerize(widget, switch, box_expand, box_fill, box_padding)
        add_class_to_css(switch, class_name)

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
