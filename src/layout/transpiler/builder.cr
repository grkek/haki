require "gobject/gtk"
require "uuid"

module Layout
  module Transpiler
    include Layout::Dom

    class Builder
      property application : Gtk::Application?
      property window : Gtk::ApplicationWindow?
      property components = {} of String => Pointer(LibGtk::Widget)

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

              get_element_by_id_proc = ->(id : String) {
                @components[id].as(Pointer(LibGtk::Widget))
              }

              context = Layout::Js::Engine::INSTANCE.runtime.context

              context.push_heap_stash
              context.push_pointer(::Box.box(get_element_by_id_proc))
              context.put_prop_string(-2, "getElementByIdClosure")

              context.push_global_proc("getElementById", 1) do |ptr|
                env = Duktape::Sandbox.new(ptr)
                env.push_heap_stash
                env.get_prop_string(-1, "getElementByIdClosure")
                function = ::Box(Proc(String, Pointer(LibGtk::Widget))).unbox(env.get_pointer(-1))
                component_id = env.get_string(0).not_nil!
                pointer = function.call(component_id)
                widget = pointer.as(Gtk::Widget)

                set_opacity_proc = ->(opacity : Float64) { widget.opacity = opacity }
                set_visibility_proc = ->(visible : Bool) { widget.visible = visible }
                set_text_proc = ->(text : String) { widget.as(Gtk::Label).text = text }

                env.push_heap_stash
                env.push_pointer(::Box.box(set_opacity_proc))
                env.put_prop_string(-2, "setOpacityClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_visibility_proc))
                env.put_prop_string(-2, "setVisibilityClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_text_proc))
                env.put_prop_string(-2, "setTextClosure")

                idx = env.push_object

                env.push_proc(1) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setOpacityClosure")
                  proc = ::Box(Proc(Float64, Nil)).unbox(sbx.get_pointer(-1))
                  opacity = sbx.get_number(0).not_nil!.as(Float64)
                  proc.call(opacity)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setOpacity")

                env.push_proc(1) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setVisibilityClosure")
                  proc = ::Box(Proc(Bool, Nil)).unbox(sbx.get_pointer(-1))
                  visible = sbx.get_boolean(0).not_nil!
                  proc.call(visible)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setVisible")

                env.push_proc(1) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setTextClosure")
                  proc = ::Box(Proc(String, Nil)).unbox(sbx.get_pointer(-1))
                  text = sbx.get_string(0).not_nil!
                  proc.call(text)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setText")

                env.push_number(widget.opacity)
                env.put_prop_string(idx, "opacity")

                env.push_boolean(widget.visible)
                env.put_prop_string(idx, "visible")
                env.call_success
              end

              context.push_heap_stash
              context.push_pointer(::Box.box(get_element_by_id_proc))
              context.put_prop_string(-2, "setElementOpacityByIdClosure")

              context.push_global_proc("setElementOpacityById", 2) do |ptr|
                env = Duktape::Sandbox.new(ptr)
                env.push_heap_stash
                env.get_prop_string(-1, "setElementOpacityByIdClosure")
                function = ::Box(Proc(String, Pointer(LibGtk::Widget))).unbox(env.get_pointer(-1))
                component_id = env.get_string(0).not_nil!
                component_value = env.get_number(1).not_nil!.as(Float64)
                widget = function.call(component_id)
                idx = env.push_object
                widget = widget.as(Gtk::Widget)

                widget.opacity = component_value

                env.call_success
              end

              context.push_heap_stash
              context.push_pointer(::Box.box(get_element_by_id_proc))
              context.put_prop_string(-2, "setElementVisibilityByIdClosure")

              context.push_global_proc("setElementVisibilityById", 2) do |ptr|
                env = Duktape::Sandbox.new(ptr)
                env.push_heap_stash
                env.get_prop_string(-1, "setElementVisibilityByIdClosure")
                function = ::Box(Proc(String, Pointer(LibGtk::Widget))).unbox(env.get_pointer(-1))
                component_id = env.get_string(0).not_nil!
                component_value = env.get_boolean(1).not_nil!
                widget = function.call(component_id)
                idx = env.push_object
                widget = widget.as(Gtk::Widget)

                widget.visible = component_value

                env.call_success
              end

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

          if id
            @components[id.not_nil!] = button.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(button, nil)
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

          if id
            @components[id.not_nil!] = entry.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(entry, nil)
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

          if id
            @components[id.not_nil!] = switch.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(switch, nil)
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

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          child.on_component_did_mount

          if id
            @components[id.not_nil!] = image.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(image, nil)
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

          if id
            @components[id.not_nil!] = label.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(label, nil)
          when Gtk::Box
            widget.pack_start(label, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(label)
          end
        when StyleSheet
          process_stylesheet(child)
        when Tab
          id = child.attributes["id"]? || nil
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          tab = Gtk::Notebook.new(name: id, halign: horizontal_align, valign: vertical_align)

          child.children.each do |subchild|
            build_widget(subchild, tab)
          end

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          child.on_component_did_mount

          if id
            @components[id.not_nil!] = tab.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(tab, nil)
          when Gtk::Box
            widget.pack_start(tab, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
          when Gtk::ApplicationWindow
            widget.add(tab)
          end
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

          if id
            @components[id.not_nil!] = box.as(Pointer(LibGtk::Widget))
          end

          case widget
          when Gtk::Notebook
            widget.append_page(box, nil)
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

            window_resize_proc = ->(width : Int32, height : Int32) {
              @window.not_nil!.resize(width, height)
            }

            context = Layout::Js::Engine::INSTANCE.runtime.context

            context.push_heap_stash
            context.push_pointer(::Box.box(window_resize_proc))
            context.put_prop_string(-2, "resizeWindowClosure")

            context.push_global_proc("resizeWindow", 2) do |ptr|
              env = Duktape::Sandbox.new(ptr)
              env.push_heap_stash
              env.get_prop_string(-1, "resizeWindowClosure")
              function = ::Box(Proc(Int32, Int32, Nil)).unbox(env.get_pointer(-1))
              function.call(env.get_int(0), env.get_int(1))
              env.call_success
            end

            child.on_component_did_mount

            if id
              @components[id.not_nil!] = @window.not_nil!.as(Pointer(LibGtk::Widget))
            end

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
