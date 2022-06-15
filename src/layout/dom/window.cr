require "./node"
require "./element"

module Layout
  module Dom
    class Window < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes, @children)
        @kind = "Window"
        substitution()
      end

      def initialize_component(widget : Gtk::Application)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        title = @attributes["title"]? || "Untitled"
        width = @attributes["width"]? || "800"
        height = @attributes["height"]? || "600"

        if width.includes?(".0")
          width = width[..width.size - 3]
        end

        if height.includes?(".0")
          height = height[..height.size - 3]
        end

        window = Gtk::ApplicationWindow.new(
          name: id,
          application: widget,
          title: title,
          default_width: width.to_i,
          default_height: height.to_i
        )

        window.try(&.connect "destroy", &->exit)
        window.position = Gtk::WindowPosition::CENTER_ALWAYS

        add_class_to_css(window, class_name)

        window
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
