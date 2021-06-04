require "./node"
require "./element"

module Layout
  module Dom
    class Image < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes)
        @kind = "Image"
        @children = [] of Node
        substitution()
      end

      def initialize_component(widget : Gtk::Widget, component_storage : Transpiler::ComponentStorage)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        source = @attributes["src"]? || ""

        width = @attributes["width"]? || "256"
        height = @attributes["height"]? || "256"

        preserve_aspect_ration = @attributes["preserveAspectRation"]? || "true"

        if width.includes?(".0")
          width = width[..width.size - 3]
        end

        if height.includes?(".0")
          height = height[..height.size - 3]
        end

        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        if width && height
          image = Gtk::Image.new(
            name: id,
            # TODO: Create an issue in the GTK bindings repository.
            # pixbuf: GdkPixbuf::Pixbuf.new_from_file_at_scale(source, width.to_i, height.to_i, to_bool(preserve_aspect_ration)),
            halign: horizontal_align,
            valign: vertical_align
          )
        else
          image = Gtk::Image.new(
            name: id,
            file: source,
            halign: horizontal_align,
            valign: vertical_align
          )
        end

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        containerize(widget, image, box_expand, box_fill, box_padding)

        image.on_event_after do |widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            did_update(@cid, event.event_type.to_s)
            true
          end
        end

        add_class_to_css(image, class_name)

        component_storage.store(id, image)
        component_storage.store(@cid, image)
        did_mount(@cid)

        image
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
