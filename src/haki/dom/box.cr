require "./node"
require "./element"

module Haki
  module Dom
    class Box < Element
      property attributes : Hash(String, String)

      def initialize(@attributes, @children)
        @kind = "Box"
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

        case @attributes["orientation"]?
        when "vertical"
          orientation = Gtk::Orientation::Vertical
        when "horizontal"
          orientation = Gtk::Orientation::Horizontal
        else
          orientation = Gtk::Orientation::Vertical
        end

        spacing = @attributes["spacing"]? || "2"

        box = Gtk::Box.new(name: id, orientation: orientation, spacing: spacing.to_i, halign: horizontal_align, valign: vertical_align)

        Duktape::Engine.instance.eval! ["const", id, "=", {type: "Box", className: class_name, availableCallbacks: ["onEvent"]}.to_json].join(" ")

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
        # box.add_controller(event_controller)

        containerize(widget, box, box_expand, box_fill, box_padding)
        add_class_to_css(box, class_name)

        box
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
