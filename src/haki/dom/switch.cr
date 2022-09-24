require "./node"
require "./element"

module Haki
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

        Duktape::Engine.instance.eval! ["const", id, "=", {type: "Switch", className: class_name, availableCallbacks: ["onStateSet", "onEvent"]}.to_json].join(" ")

        # switch.state_set_signal.connect do
        #   Duktape::Engine.instance.eval! [id, ".", "onStateSet", "(", switch.active, ")"].join

        #   true
        # end

        # event_controller = Gtk::EventControllerLegacy.new
        # event_controller.event_signal.connect(after: true) do |event|
        #   case event.event_type
        #   when Gdk::EventType::MotionNotify
        #     false
        #   else
        #     Duktape::Engine.instance.eval! [id, ".", "onEvent", "(", "\"", event.event_type.to_s, "\"", ")"].join
        #     true
        #   end
        # end
        # switch.add_controller(event_controller)

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
