require "./node"
require "./element"

module Haki
  module Dom
    class Button < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes, @children)
        @kind = "Button"
        substitution()
      end

      def initialize_component(widget : Gtk::Widget) : Gtk::Widget
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        relief = @attributes["relief"]? || nil
        text = children.first.as(Text).data.to_s

        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        case relief
        when "none"
          relief_style = false
        when "normal"
          relief_style = true
        else
          relief_style = false
        end

        button = Gtk::Button.new(name: id, label: text, has_frame: relief_style, halign: horizontal_align, valign: vertical_align)

        Duktape::Engine.instance.eval! ["const", id, "=", {type: "Button", className: class_name, availableCallbacks: ["onEvent", "onClick"]}.to_json].join(" ")

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
        # button.add_controller(event_controller)

        button.clicked_signal.connect do
          Duktape::Engine.instance.eval! [id, ".", "onClick", "()"].join
        end

        containerize(widget, button, box_expand, box_fill, box_padding)
        add_class_to_css(button, class_name)

        button
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
