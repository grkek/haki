require "gobject/gtk"
require "uuid"

module Layout
  module Transpiler
    include Layout::Dom

    MAX_LIST_BOX_SIZE = 1000000 # A quick hack around the NULL pointer error to avoid messy orders.

    class Builder
      property application : Gtk::Application?
      property window : Gtk::ApplicationWindow?
      property elements = {} of String => Pointer(LibGtk::Widget)
      property components = {} of String => Pointer(LibGtk::Widget)

      def build_from_document(document)
        File.open(document) do |fd|
          structure = Layout::Parser.parse(fd.gets_to_end)

          case structure
          when Application
            @application = Gtk::Application.new(
              application_id: structure.as(Element).attributes["gid"]? || "com.layer.untitled"
            )

            @application.try(&.on_activate do
              get_element_by_class_id_proc = ->(class_id : String) {
                @elements[class_id].as(Pointer(LibGtk::Widget))
              }

              get_element_by_id_proc = ->(id : String) {
                @components[id].as(Pointer(LibGtk::Widget))
              }

              context = Layout::Js::Engine::INSTANCE.runtime.context

              context.push_heap_stash
              context.push_pointer(::Box.box(get_element_by_class_id_proc))
              context.put_prop_string(-2, "getElementByClassIdClosure")

              context.push_global_proc("getElementByClassId", 1) do |ptr|
                env = Duktape::Sandbox.new(ptr)
                env.push_heap_stash
                env.get_prop_string(-1, "getElementByClassIdClosure")
                function = ::Box(Proc(String, Pointer(LibGtk::Widget))).unbox(env.get_pointer(-1))
                component_id = env.get_string(0).not_nil!
                pointer = function.call(component_id)
                widget = pointer.as(Gtk::Widget)

                set_opacity_proc = ->(opacity : Float64) { widget.opacity = opacity }
                set_visibility_proc = ->(visible : Bool) { widget.visible = visible }
                set_foreground_color_proc = ->(r : Float64, g : Float64, b : Float64, a : Float64) { widget.override_color(Gtk::StateFlags::NORMAL, Gdk::RGBA.new(r, g, b, a)) }
                set_background_color_proc = ->(r : Float64, g : Float64, b : Float64, a : Float64) { widget.override_background_color(Gtk::StateFlags::NORMAL, Gdk::RGBA.new(r, g, b, a)) }

                set_text_proc = ->(text : String) {
                  begin
                    widget.as(Gtk::Entry).text = text
                  rescue
                    widget.as(Gtk::Label).text = text
                  end
                }

                get_text_proc = ->{
                  begin
                    widget.as(Gtk::Entry).text
                  rescue
                    widget.as(Gtk::Label).text
                  end
                }

                env.push_heap_stash
                env.push_pointer(::Box.box(set_opacity_proc))
                env.put_prop_string(-2, "setOpacityClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_visibility_proc))
                env.put_prop_string(-2, "setVisibilityClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_text_proc))
                env.put_prop_string(-2, "setTextClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(get_text_proc))
                env.put_prop_string(-2, "getTextClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_foreground_color_proc))
                env.put_prop_string(-2, "setForegroundColorClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_background_color_proc))
                env.put_prop_string(-2, "setBackgroundColorClosure")

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

                env.push_proc(1) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "getTextClosure")
                  proc = ::Box(Proc(String)).unbox(sbx.get_pointer(-1))
                  sbx.push_string(proc.call)
                  sbx.call_success
                end

                env.put_prop_string(-2, "getText")

                env.push_proc(4) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setForegroundColorClosure")
                  proc = ::Box(Proc(Float64, Float64, Float64, Float64, Nil)).unbox(sbx.get_pointer(-1))

                  r = sbx.get_number(0).not_nil!
                  g = sbx.get_number(1).not_nil!
                  b = sbx.get_number(2).not_nil!
                  a = sbx.get_number(3).not_nil!

                  proc.call(r.to_f64, g.to_f64, b.to_f64, a.to_f64)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setForegroundColor")

                env.push_proc(4) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setBackgroundColorClosure")
                  proc = ::Box(Proc(Float64, Float64, Float64, Float64, Nil)).unbox(sbx.get_pointer(-1))

                  r = sbx.get_number(0).not_nil!
                  g = sbx.get_number(1).not_nil!
                  b = sbx.get_number(2).not_nil!
                  a = sbx.get_number(2).not_nil!

                  proc.call(r.to_f64, g.to_f64, b.to_f64, a.to_f64)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setBackgroundColor")

                env.push_number(widget.opacity)
                env.put_prop_string(idx, "opacity")

                env.push_boolean(widget.visible)
                env.put_prop_string(idx, "visible")
                env.call_success
              end

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
                set_foreground_color_proc = ->(r : Float64, g : Float64, b : Float64, a : Float64) { widget.override_color(Gtk::StateFlags::NORMAL, Gdk::RGBA.new(r, g, b, a)) }
                set_background_color_proc = ->(r : Float64, g : Float64, b : Float64, a : Float64) { widget.override_background_color(Gtk::StateFlags::NORMAL, Gdk::RGBA.new(r, g, b, a)) }

                set_text_proc = ->(text : String) {
                  begin
                    widget.as(Gtk::Entry).text = text
                  rescue
                    widget.as(Gtk::Label).text = text
                  end
                }

                get_text_proc = ->{
                  begin
                    widget.as(Gtk::Entry).text
                  rescue
                    widget.as(Gtk::Label).text
                  end
                }

                env.push_heap_stash
                env.push_pointer(::Box.box(set_opacity_proc))
                env.put_prop_string(-2, "setOpacityClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_visibility_proc))
                env.put_prop_string(-2, "setVisibilityClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_text_proc))
                env.put_prop_string(-2, "setTextClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(get_text_proc))
                env.put_prop_string(-2, "getTextClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_foreground_color_proc))
                env.put_prop_string(-2, "setForegroundColorClosure")

                env.push_heap_stash
                env.push_pointer(::Box.box(set_background_color_proc))
                env.put_prop_string(-2, "setBackgroundColorClosure")

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

                env.push_proc(1) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "getTextClosure")
                  proc = ::Box(Proc(String)).unbox(sbx.get_pointer(-1))
                  sbx.push_string(proc.call)
                  sbx.call_success
                end

                env.put_prop_string(-2, "getText")

                env.push_proc(4) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setForegroundColorClosure")
                  proc = ::Box(Proc(Float64, Float64, Float64, Float64, Nil)).unbox(sbx.get_pointer(-1))

                  r = sbx.get_number(0).not_nil!
                  g = sbx.get_number(1).not_nil!
                  b = sbx.get_number(2).not_nil!
                  a = sbx.get_number(3).not_nil!

                  proc.call(r.to_f64, g.to_f64, b.to_f64, a.to_f64)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setForegroundColor")

                env.push_proc(4) do |ptr|
                  sbx = Duktape::Sandbox.new(ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setBackgroundColorClosure")
                  proc = ::Box(Proc(Float64, Float64, Float64, Float64, Nil)).unbox(sbx.get_pointer(-1))

                  r = sbx.get_number(0).not_nil!
                  g = sbx.get_number(1).not_nil!
                  b = sbx.get_number(2).not_nil!
                  a = sbx.get_number(2).not_nil!

                  proc.call(r.to_f64, g.to_f64, b.to_f64, a.to_f64)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setBackgroundColor")

                env.push_number(widget.opacity)
                env.put_prop_string(idx, "opacity")

                env.push_boolean(widget.visible)
                env.put_prop_string(idx, "visible")
                env.call_success
              end

              structure.as(Element).on_component_did_mount

              # Do a little benchmark of how long it takes to build
              # the structure.
              puts "Building components..."
              elapsed_time = Time.measure { build_components(structure) }
              puts "Finished. #{elapsed_text(elapsed_time)}"
              @window.try(&.show_all)
            end)
          else
            # TODO: Refactor this later to an actual error message.
            raise "The first component always must be an application."
          end
        end
      end

      private def elapsed_text(elapsed)
        millis = elapsed.total_milliseconds
        return "#{millis.round(2)}ms" if millis >= 1

        "#{(millis * 1000).round(2)}µs"
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

      private def add_class_to_css(widget, class_name)
        if class_name
          context = widget.style_context
          context.add_class(class_name.not_nil!)
        end
      end

      private def to_bool(str : String) : Bool
        if str == "true"
          true
        else
          false
        end
      end

      private def containerize(widget, component, box_expand, box_fill, box_padding)
        case widget
        when Gtk::Notebook
          widget.append_page(component, nil)
        when Gtk::Box
          widget.pack_start(component, to_bool(box_expand), to_bool(box_fill), box_padding.to_i)
        when Gtk::ScrolledWindow, Gtk::Frame
          widget.add(component)
        when Gtk::ListBox
          widget.insert(component, MAX_LIST_BOX_SIZE)
        when Gtk::ApplicationWindow
          widget.add(component)
        end
      end

      # ameba:disable Metrics/CyclomaticComplexity
      private def transpile_component(child, widget : Gtk::Widget)
        case child
        when Text
        else
          unless child.as(Element).attributes["classId"]?
            child.as(Element).attributes["classId"] = "#{child.kind.downcase}#{UUID.random.hexstring}"
          end
        end

        case child
        when Button
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
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

          button.on_clicked do
            Layout::Js::Engine::INSTANCE.evaluate("#{on_click}()")
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = button.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = button.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, button, box_expand, box_fill, box_padding)

          button.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(button, class_name)
          child.on_component_did_mount
        when TextInput
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          label = child.attributes["value"]? || nil
          placeholder = child.attributes["placeholder"]? || nil
          text_changed = child.attributes["onChangeText"]? || nil
          cut_clipboard = child.attributes["onCut"]? || nil
          copy_clipboard = child.attributes["onCopy"]? || nil
          paste_clipboard = child.attributes["onPaste"]? || nil
          on_activate = child.attributes["onActivate"]? || nil

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

          entry.buffer.on_deleted_text do |buffer|
            if text_changed
              Layout::Js::Engine::INSTANCE.evaluate("#{text_changed}('#{buffer.text}')")
            end
          end

          entry.on_cut_clipboard do
            if cut_clipboard
              Layout::Js::Engine::INSTANCE.evaluate("#{cut_clipboard}('#{entry.buffer.text}')")
            end
          end

          entry.on_copy_clipboard do
            if copy_clipboard
              Layout::Js::Engine::INSTANCE.evaluate("#{copy_clipboard}('#{entry.buffer.text}')")
            end
          end

          entry.on_paste_clipboard do
            if paste_clipboard
              Layout::Js::Engine::INSTANCE.evaluate("#{paste_clipboard}('#{entry.buffer.text}')")
            end
          end

          entry.on_activate do
            if on_activate
              Layout::Js::Engine::INSTANCE.evaluate("#{on_activate}('#{entry.buffer.text}')")
            end
          end

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = entry.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = entry.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, entry, box_expand, box_fill, box_padding)

          entry.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(entry, class_name)
          child.on_component_did_mount
        when Switch
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil

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

          if class_id = child.attributes["classId"]?
            @elements[class_id] = switch.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = switch.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, switch, box_expand, box_fill, box_padding)

          switch.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(switch, class_name)
          child.on_component_did_mount
        when Image
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          source = child.attributes["src"]? || ""

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

          if class_id = child.attributes["classId"]?
            @elements[class_id] = image.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = image.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, image, box_expand, box_fill, box_padding)

          image.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(image, class_name)
          child.on_component_did_mount
        when Label
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          text = child.children[0].as(Text).data.to_s
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          label = Gtk::Label.new(name: id, label: text, halign: horizontal_align, valign: vertical_align, wrap: true)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = label.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = label.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, label, box_expand, box_fill, box_padding)

          label.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(label, class_name)
          child.on_component_did_mount
        when TextView
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          text = child.children[0].as(Text).data.to_s
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          text_view = Gtk::TextView.new(name: id, halign: horizontal_align, valign: vertical_align)
          text_view.buffer.set_text(text, text.size)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = text_view.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = text_view.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, text_view, box_expand, box_fill, box_padding)

          text_view.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(text_view, class_name)
          child.on_component_did_mount
        when Tab
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          tab = Gtk::Notebook.new(name: id, halign: horizontal_align, valign: vertical_align)

          child.children.each do |subchild|
            transpile_component(subchild, tab)
          end

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = tab.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = tab.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, tab, box_expand, box_fill, box_padding)

          tab.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(tab, class_name)
          child.on_component_did_mount
        when Box
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
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
            transpile_component(subchild, box)
          end

          box.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = box.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = box.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, box, box_expand, box_fill, box_padding)

          add_class_to_css(box, class_name)
          child.on_component_did_mount
        when Frame
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          value = child.attributes["value"]? || ""
          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          spacing = child.attributes["spacing"]? || "2"

          frame = Gtk::Frame.new(name: id, label: value, halign: horizontal_align, valign: vertical_align)

          child.children.each do |subchild|
            transpile_component(subchild, frame)
          end

          frame.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = frame.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = frame.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, frame, box_expand, box_fill, box_padding)

          add_class_to_css(frame, class_name)
          child.on_component_did_mount
        when ScrolledWindow
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")
          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          spacing = child.attributes["spacing"]? || "2"

          scrolled_window = Gtk::ScrolledWindow.new(name: id, halign: horizontal_align, valign: vertical_align)

          child.children.each do |subchild|
            transpile_component(subchild, scrolled_window)
          end

          scrolled_window.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = scrolled_window.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = scrolled_window.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, scrolled_window, box_expand, box_fill, box_padding)

          add_class_to_css(scrolled_window, class_name)
          child.on_component_did_mount
        when VerticalSeparator
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          vertical_separator = Gtk::Separator.new(name: id, orientation: Gtk::Orientation::VERTICAL, halign: horizontal_align, valign: vertical_align)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = vertical_separator.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = vertical_separator.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, vertical_separator, box_expand, box_fill, box_padding)

          vertical_separator.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(vertical_separator, class_name)
          child.on_component_did_mount
        when HorizontalSeparator
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          horizontal_separator = Gtk::Separator.new(name: id, orientation: Gtk::Orientation::HORIZONTAL, halign: horizontal_align, valign: vertical_align)

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = horizontal_separator.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = horizontal_separator.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, horizontal_separator, box_expand, box_fill, box_padding)

          horizontal_separator.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(horizontal_separator, class_name)
          child.on_component_did_mount
        when ListBox
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
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

          list_box = Gtk::ListBox.new(name: id, halign: horizontal_align, valign: vertical_align)

          child.children.each do |subchild|
            transpile_component(subchild, list_box)
          end

          list_box.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = list_box.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = list_box.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, list_box, box_expand, box_fill, box_padding)

          add_class_to_css(list_box, class_name)
          child.on_component_did_mount
        when Spinner
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil
          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          spinner = Gtk::Spinner.new(
            name: id,
            halign: horizontal_align,
            valign: vertical_align,
            active: true
          )

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = spinner.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = spinner.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, spinner, box_expand, box_fill, box_padding)

          spinner.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(spinner, class_name)
          child.on_component_did_mount
        when ProgressBar
          id = child.attributes["id"]? || nil
          class_name = child.attributes["class"]? || nil

          value = child.attributes["value"]? || ""
          inverted = to_bool(child.attributes["inverted"]? || "false")

          horizontal_align = to_align(child.attributes["horizontalAlign"]? || "")
          vertical_align = to_align(child.attributes["verticalAlign"]? || "")

          progress_bar = Gtk::ProgressBar.new(
            name: id,
            text: value,
            inverted: inverted,
            show_text: value.size != 0,
            halign: horizontal_align,
            valign: vertical_align
          )

          box_expand = child.attributes["boxExpand"]? || "false"
          box_fill = child.attributes["boxFill"]? || "false"
          box_padding = child.attributes["boxPadding"]? || "0"

          if box_padding.includes?(".0")
            box_padding = box_padding[..box_padding.size - 3]
          end

          if class_id = child.attributes["classId"]?
            @elements[class_id] = progress_bar.as(Pointer(LibGtk::Widget))
          end

          if id = child.attributes["id"]?
            @components[id] = progress_bar.as(Pointer(LibGtk::Widget))
          end

          containerize(widget, progress_bar, box_expand, box_fill, box_padding)

          progress_bar.on_event_after do |widget, event|
            case event.event_type
            when Gdk::EventType::MOTION_NOTIFY
              false
            else
              child.on_component_did_update(child.attributes["classId"], event.event_type.to_s)
              true
            end
          end

          add_class_to_css(progress_bar, class_name)
          child.on_component_did_mount
        when EventBox
          nil
        else
          nil
        end
      end

      private def recursive_stylesheet_processing(parent)
        parent.children.each do |child|
          case child
          when StyleSheet
            process_stylesheet(child)
          else
            recursive_stylesheet_processing(child)
          end
        end
      end

      # ameba:disable Metrics/CyclomaticComplexity
      private def transpile_components(parent, widget : Gtk::Widget)
        recursive_stylesheet_processing(parent)

        parent.children.each do |child|
          transpile_component(child, widget.not_nil!)
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
            class_name = child.attributes["class"]? || nil
            title = child.attributes["title"]? || "Untitled"
            width = child.attributes["width"]? || "800"
            height = child.attributes["height"]? || "600"

            unless child.as(Element).attributes["classId"]?
              child.as(Element).attributes["classId"] = "#{child.kind.downcase}#{UUID.random.hexstring}"
            end

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

            if class_id = child.attributes["classId"]?
              @elements[class_id] = @window.not_nil!.as(Pointer(LibGtk::Widget))
            end

            if id = child.attributes["id"]?
              @components[id] = @window.not_nil!.as(Pointer(LibGtk::Widget))
            end

            @window.not_nil!.position = Gtk::WindowPosition::CENTER_ALWAYS

            child.on_component_did_mount
            add_class_to_css(@window.not_nil!, class_name)
            transpile_components(child, @window.not_nil!)
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
