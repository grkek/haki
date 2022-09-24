require "./node"
require "./element"

module Haki
  module Dom
    class HorizontalSeparator < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes)
        @kind = "HorizontalSeparator"
        @children = [] of Node
        substitution()
      end

      def initialize_component(widget : Gtk::Widget)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil

        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        horizontal_separator = Gtk::Separator.new(name: id, orientation: Gtk::Orientation::Horizontal, halign: horizontal_align, valign: vertical_align)

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

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
        # horizontal_separator.add_controller(event_controller)

        containerize(widget, horizontal_separator, box_expand, box_fill, box_padding)
        add_class_to_css(horizontal_separator, class_name)

        horizontal_separator
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
