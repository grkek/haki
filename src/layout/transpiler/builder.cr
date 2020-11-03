require "gobject/gtk"
require "uuid"

module Layout
  module Transpiler
    include Layout::Dom

    class Builder
      property application : Gtk::Application?
      property window : Gtk::ApplicationWindow?
      property components = [] of Gtk::Widget

      def initialize
        Layout::Js::Engine::INSTANCE.evaluate("const components = {};")
      end

      def build_from_document(document)
        File.open(document) do |fd|
          structure = Layout::Parser.parse(fd.gets_to_end)

          case structure
          when Application
            @application = Gtk::Application.new(
              application_id: structure.as(Element).attributes["gid"]? || "com.layer.untitled"
            )

            @application.try(&.on_activate do
              structure.as(Element).on_component_did_mount
              build_components(structure)
              @window.try(&.show_all)
            end)
          else
            # TODO: Refactor this later to an actual error message.
            raise "The first component must always be an application."
          end
        end
      end

      private def to_align(str : String) : Gtk::Align
        case str
        when "fill"
          Gtk::Align::FILL
        when "start"
          Gtk::Align::START
        when "end"
          Gtk::Align::END
        when "center"
          Gtk::Align::CENTER
        when "baseline"
          Gtk::Align::BASELINE
        else
          Gtk::Align::BASELINE
        end
      end

      private def to_bool(str : String) : Bool
        if str == "true"
          true
        else
          false
        end
      end

      # ameba:disable Metrics/CyclomaticComplexity
      private def build_widget(child, widget : Gtk::Widget)
        case child
        when Button
          id = child.attributes["id"]? || nil
          relief = child.attributes["relief"]? || nil
          text = child.children[0].as(Text).data.to_s
          on_click = child.attributes["onClick"]? || ""

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          case relief
          when "none"
            relief_style = Gtk::ReliefStyle::NONE
          when "normal"
            relief_style = Gtk::ReliefStyle::NORMAL
          else
            relief_style = Gtk::ReliefStyle::NORMAL
          end

          button = Gtk::Button.new(name: id, label: text, relief: relief_style, halign: horizontal_align, valign: vertical_align)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          child.on_component_did_mount

          button.on_clicked do
            Layout::Js::Engine::INSTANCE.evaluate("#{on_click}()")
          end

          case widget
          when Gtk::Box
            widget.pack_start(button, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(button)
          end
        when TextInput
          id = child.attributes["id"]? || nil
          label = child.attributes["label"]? || nil
          placeholder = child.attributes["placeholder"]? || nil
          text_changed = child.attributes["onChangeText"]? || nil

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          password_char = child.attributes["passwordCharacter"]? || nil
          visibility = to_bool(child.attributes["isPassword"]? || "false") ? false : true
          invisible_char = password_char.try(&.bytes.first.to_u32)
          entry = Gtk::Entry.new(name: id, text: label, placeholder_text: placeholder, invisible_char: invisible_char, visibility: visibility, halign: horizontal_align, valign: vertical_align)

          entry.buffer.on_inserted_text do |buffer|
            if text_changed
              Layout::Js::Engine::INSTANCE.evaluate("#{text_changed}('#{buffer.text}')")
            end
          end

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          child.on_component_did_mount

          case widget
          when Gtk::Box
            widget.pack_start(entry, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(entry)
          end
        when Switch
          id = child.attributes["id"]? || nil

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          value = to_bool(child.attributes["value"]? || "false")

          switch = Gtk::Switch.new(name: id, halign: horizontal_align, valign: vertical_align, state: value)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          value_change = child.attributes["onValueChange"]? || nil

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          switch.on_state_set do
            if value_change
              Layout::Js::Engine::INSTANCE.evaluate("#{value_change}(#{switch.active})")
            end

            true
          end

          child.on_component_did_mount

          case widget
          when Gtk::Box
            widget.pack_start(switch, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(switch)
          end
        when Image
          id = child.attributes["id"]? || nil
          source = child.attributes["source"]? || ""

          width = child.attributes["width"]? || "256"
          height = child.attributes["height"]? || "256"

          preserve_aspect_ration = child.attributes["preserveAspectRation"]? || "true"

          if width.includes?(".0")
            width = width[..width.size - 3]
          end

          if height.includes?(".0")
            height = height[..height.size - 3]
          end

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          if width && height
            image = Gtk::Image.new(
              name: id,
              pixbuf: GdkPixbuf::Pixbuf.new_from_file_at_scale(source, width.to_i, height.to_i, to_bool(preserve_aspect_ration)),
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

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          child.on_component_did_mount

          case widget
          when Gtk::Box
            widget.pack_start(image, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(image)
          end
        when Label
          id = child.attributes["id"]? || nil
          text = child.children[0].as(Text).data.to_s
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          label = Gtk::Label.new(name: id, label: text, halign: horizontal_align, valign: vertical_align)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          child.on_component_did_mount

          case widget
          when Gtk::Box
            widget.pack_start(label, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(label)
          end
        when StyleSheet
          process_stylesheet(child)
        when Box
          id = child.attributes["id"]? || nil
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          case child.attributes["orientation"]?
          when "vertical"
            orientation = Gtk::Orientation::VERTICAL
          when "horizontal"
            orientation = Gtk::Orientation::HORIZONTAL
          else
            orientation = Gtk::Orientation::VERTICAL
          end

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          spacing = child.attributes["spacing"]? || "2"

          box = Gtk::Box.new(name: id, orientation: orientation, spacing: spacing.to_i, halign: horizontal_align, valign: vertical_align)

          child.children.each do |subchild|
            build_widget(subchild, box)
          end

          child.on_component_did_mount

          case widget
          when Gtk::Box
            widget.pack_start(box, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(box)
          end
        when EventBox
          nil
        else
          nil
        end
      end

      # ameba:disable Metrics/CyclomaticComplexity
      private def build_widgets(parent, widget : Gtk::Widget)
        parent.children.each do |child|
          build_widget(child, widget.not_nil!)
        end
      end

      private def process_stylesheet(child)
        css_provider = Gtk::CssProvider.new
        css_provider.load_from_path(child.attributes["src"])
        display = Gdk::Display.default.not_nil!
        screen = display.default_screen
        Gtk::StyleContext.add_provider_for_screen screen, css_provider, Gtk::STYLE_PROVIDER_PRIORITY_APPLICATION
      end

      private def build_components(document)
        document.children.each do |child|
          case child
          when StyleSheet
            process_stylesheet(child)
          when Window
            id = child.attributes["id"]? || nil
            title = child.attributes["title"]? || "Untitled"
            width = child.attributes["width"]? || "800"
            height = child.attributes["height"]? || "600"

            if width.includes?(".0")
              width = width[..width.size - 3]
            end

            if height.includes?(".0")
              height = height[..height.size - 3]
            end

            @window = Gtk::ApplicationWindow.new(
              name: id,
              application: @application.not_nil!,
              title: title,
              default_width: width.to_i,
              default_height: height.to_i
            )

            @window.try(&.connect "destroy", &->exit)

            child.on_component_did_mount
            build_widgets(child, @window.not_nil!)
          else
            # TODO: Handle other non-crucial parts.
          end
        end
      end

      def run
        @application.try(&.run)
      end
    end
  end
end
