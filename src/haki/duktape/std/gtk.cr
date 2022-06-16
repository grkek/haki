require "http/client"

module Haki
  module Duktape
    module Std
      module Gtk
        macro gtk
          context.push_global_proc("__std__load_style_sheets__", 2) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)
            folder = sbx.require_string(0)

            if sbx.is_array(1)
              length = sbx.get_length(1)

              length.times do |i|
                sbx.get_prop_index(1, i.to_u32)
                file = sbx.require_string(-1)

                css_provider = Gtk::CssProvider.new
                css_provider.load_from_path([folder, file].join("/"))
                display = Gdk::Display.default.not_nil!
                screen = display.default_screen
                Gtk::StyleContext.add_provider_for_screen screen, css_provider, Gtk::STYLE_PROVIDER_PRIORITY_APPLICATION
              end

              sbx.call_success
            else
              raise ::Duktape::Error.new("`__std__load_style_sheets__` function requires an array as a second argument.")
            end
          end

          context.push_global_proc("__std__load_style_sheet__", 1) do |ptr|
            sbx = ::Duktape::Sandbox.new(ptr)
            file = sbx.require_string(0)

            css_provider = Gtk::CssProvider.new
            css_provider.load_from_path(file)
            display = Gdk::Display.default.not_nil!
            screen = display.default_screen
            Gtk::StyleContext.add_provider_for_screen screen, css_provider, Gtk::STYLE_PROVIDER_PRIORITY_APPLICATION
            sbx.call_success
          end

          context.eval! <<-JS
            const gtk = {
              loadStyleSheet: function(path) { __std__load_style_sheet__(path); },
              loadStyleSheets: function(path, sheets) { __std__load_style_sheets__(path, sheets); }
            };
          JS
        end
      end
    end
  end
end
