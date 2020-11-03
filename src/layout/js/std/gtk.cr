require "http/client"

module Layout
  module Js
    module Std
      module Gtk
        macro gtk
          context.push_global_proc("loadStyleSheet", 1) do |ptr|
            sbx = Duktape::Sandbox.new(ptr)
            file = sbx.require_string(0)
            css_provider = Gtk::CssProvider.new
            css_provider.load_from_path(file)
            display = Gdk::Display.default.not_nil!
            screen = display.default_screen
            Gtk::StyleContext.add_provider_for_screen screen, css_provider, Gtk::STYLE_PROVIDER_PRIORITY_APPLICATION
            sbx.call_success
          end
        end
      end
    end
  end
end
