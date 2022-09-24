require "./node"
require "./element"

module Haki
  module Dom
    class Label < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes, @children)
        @kind = "Label"
        substitution()
      end

      def initialize_component(widget : Gtk::Widget)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        text = @children[0].as(Text).data.to_s
        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")
        label = Gtk::Label.new(name: id, label: text, halign: horizontal_align, valign: vertical_align, wrap: true)

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        Duktape::Engine.instance.eval! ["const", id, "=", {type: "Label", className: class_name, availableCallbacks: ["onEvent"], avaliableFunctions: ["currentValue"]}.to_json].join(" ")

        # event_controller = Gtk::EventControllerLegacy.new
        # event_controller.event_signal.connect(after: true) do |event|
        #   case event.event_type
        #   when Gdk::EventType::MotionNotify
        #     false
        #   else
        #     # TODO: Add an event handler for the components to forward information to JavaScript.
        #     true
        #   end
        # end
        # label.add_controller(event_controller)

        containerize(widget, label, box_expand, box_fill, box_padding)
        add_class_to_css(label, class_name)

        label
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
