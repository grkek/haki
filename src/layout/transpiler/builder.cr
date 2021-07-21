require "gobject/gtk"
require "uuid"

module Layout
  module Transpiler
    include Layout::Dom

    class Builder
      property application : Gtk::Application?
      property component_storage : ComponentStorage

      def initialize
        @component_storage = ComponentStorage.new
      end

      # Create the main application, initialize the JavaScript context and build the components.
      def build_from_document(document)
        File.open(document) do |fd|
          structure = Layout::Parser.parse(fd.gets_to_end)

          case structure
          when Application
            @application = Gtk::Application.new(
              application_id: structure.as(Element).attributes["gid"]? || "com.layer.untitled"
            )

            @application.try(&.on_activate do
              get_element_by_component_id_proc = ->(component_id : String) {
                @component_storage.retrieve(component_id)
              }

              context = Layout::Js::Engine::INSTANCE.runtime.context

              context.push_heap_stash
              context.push_pointer(::Box.box(get_element_by_component_id_proc))
              context.put_prop_string(-2, "getElementByComponentId")

              context.push_global_proc("getElementByComponentId", 1) do |ptr|
                env = Duktape::Sandbox.new(ptr)
                env.push_heap_stash
                env.get_prop_string(-1, "getElementByComponentId")
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

                env.push_proc(1) do |proc_ptr|
                  sbx = Duktape::Sandbox.new(proc_ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setOpacityClosure")
                  proc = ::Box(Proc(Float64, Nil)).unbox(sbx.get_pointer(-1))
                  opacity = sbx.get_number(0).not_nil!.as(Float64)
                  proc.call(opacity)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setOpacity")

                env.push_proc(1) do |proc_ptr|
                  sbx = Duktape::Sandbox.new(proc_ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setVisibilityClosure")
                  proc = ::Box(Proc(Bool, Nil)).unbox(sbx.get_pointer(-1))
                  visible = sbx.get_boolean(0).not_nil!
                  proc.call(visible)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setVisible")

                env.push_proc(1) do |proc_ptr|
                  sbx = Duktape::Sandbox.new(proc_ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "setTextClosure")
                  proc = ::Box(Proc(String, Nil)).unbox(sbx.get_pointer(-1))
                  text = sbx.get_string(0).not_nil!
                  proc.call(text)
                  sbx.call_success
                end

                env.put_prop_string(-2, "setText")

                env.push_proc(1) do |proc_ptr|
                  sbx = Duktape::Sandbox.new(proc_ptr)
                  sbx.push_heap_stash
                  sbx.get_prop_string(-1, "getTextClosure")
                  proc = ::Box(Proc(String)).unbox(sbx.get_pointer(-1))
                  sbx.push_string(proc.call)
                  sbx.call_success
                end

                env.put_prop_string(-2, "getText")

                env.push_proc(4) do |proc_ptr|
                  sbx = Duktape::Sandbox.new(proc_ptr)
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

                env.push_proc(4) do |proc_ptr|
                  sbx = Duktape::Sandbox.new(proc_ptr)
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

              @component_storage.store_application("MainApplication", @application.not_nil!)

              # Do a little benchmark of how long it takes to build
              # the structure.
              puts "Building components..."
              elapsed_time = Time.measure { build_components(structure, @application.not_nil!) }
              puts "Finished: #{elapsed_text(elapsed_time)}"

              cid =
                @component_storage
                  .components
                  .first

              window =
                @component_storage
                  .retrieve(cid)
                  .as(Gtk::ApplicationWindow)

              window.try(&.show_all)
            end)
          else
            # TODO: Refactor this later to an actual error message.
            raise "The first component always must be an application."
          end
        end
      end

      # Calculate the elapsed text from elapsed time.
      private def elapsed_text(elapsed)
        millis = elapsed.total_milliseconds
        return "#{millis.round(2)}ms" if millis >= 1

        "#{(millis * 1000).round(2)}µs"
      end

      # Run the initalize_component method for each child and receive an actual Gtk::Widget from it
      # then either containerize it if it is a container or just return the transpiled component.
      private def transpile_component(child, widget : Gtk::Widget)
        case child
        when Box, Frame, Tab, ListBox, ScrolledWindow
          container = child.initialize_component(widget, @component_storage)

          child.children.each do |subchild|
            transpile_component(subchild, container)
          end
        when Button, Label, TextInput, HorizontalSeparator, VerticalSeparator, Switch
          child.initialize_component(widget, @component_storage)
        else
          nil
        end
      end

      # Process the StyleSheet's first and then proceed to processing the components.
      private def transpile_components(parent, widget : Gtk::Widget)
        recursive_stylesheet_processing(parent)

        parent.children.each do |child|
          transpile_component(child, widget)
        end
      end

      # Recursively drill down the components and find StyleSheet components and process them before proceeding.
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

      # Use the Gtk::CssProvider to update the style context with the source of the CSS file.
      private def process_stylesheet(child)
        css_provider = Gtk::CssProvider.new
        css_provider.load_from_path(child.attributes["src"])
        display = Gdk::Display.default.not_nil!
        screen = display.default_screen
        Gtk::StyleContext.add_provider_for_screen screen, css_provider, Gtk::STYLE_PROVIDER_PRIORITY_APPLICATION
      end

      # Build components from the main document model, start with either a StyleSheet component or the Window component.
      private def build_components(document, widget)
        document.children.each do |child|
          case child
          when StyleSheet
            process_stylesheet(child)
          when Window
            window = child.initialize_component(widget, @component_storage)
            transpile_components(child, window)
            child.did_mount(child.cid)
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
