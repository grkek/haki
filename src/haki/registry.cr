module Haki
  class Registry
    @@instance = new

    def self.instance
      @@instance
    end

    property registered_components : Helpers::Synchronized(Hash(String, Haki::Component)) = Helpers::Synchronized(Hash(String, Haki::Component)).new

    def refresh_state(id : String)
      component = registered_components[id]

      Log.debug { "Refreshing state for a #{component.kind}, #{id}" }

      case component.kind
      when "Box"
        box = component.widget.as(Gtk::Box)

        component.state do |state|
          state["horizontalAlignment"] = JSON.parse({"id" => box.halign.to_i, "name" => box.halign.to_s}.to_json)
          state["verticalAlignment"] = JSON.parse({"id" => box.valign.to_i, "name" => box.valign.to_s}.to_json)
          state["accessibleRole"] = JSON.parse({"id" => box.accessible_role.to_i, "name" => box.accessible_role.to_s}.to_json)
          state["baselinePosition"] = JSON.parse({"id" => box.baseline_position.to_i, "name" => box.baseline_position.to_s}.to_json)
          state["canFocus"] = JSON::Any.new(box.can_focus)
          state["canTarget"] = JSON::Any.new(box.can_target)
          state["cssClasses"] = JSON.parse(box.css_classes.to_json)
          state["cssName"] = JSON::Any.new(box.css_name)
          state["focusOnClick"] = JSON::Any.new(box.focus_on_click)
          state["focusable"] = JSON::Any.new(box.focusable)
          state["hasDefault"] = JSON::Any.new(box.has_default)
          state["hasFocus"] = JSON::Any.new(box.has_focus)
          state["hasTooltip"] = JSON::Any.new(box.has_tooltip)
          state["heightRequest"] = JSON::Any.new(box.height_request.to_i64)
          state["horizontalExpand"] = JSON::Any.new(box.hexpand)
          state["horizontalExpandSet"] = JSON::Any.new(box.hexpand_set)
          state["homogeneous"] = JSON::Any.new(box.homogeneous)
          state["marginBottom"] = JSON::Any.new(box.margin_bottom.to_i64)
          state["marginEnd"] = JSON::Any.new(box.margin_end.to_i64)
          state["marginStart"] = JSON::Any.new(box.margin_start.to_i64)
          state["marginTop"] = JSON::Any.new(box.margin_top.to_i64)
          state["name"] = JSON::Any.new(box.name)
          state["opacity"] = JSON::Any.new(box.opacity)
          state["orientation"] = JSON.parse({"id" => box.orientation.to_i, "name" => box.orientation.to_s}.to_json)
          state["overflow"] = JSON.parse({"id" => box.overflow.to_i, "name" => box.overflow.to_s}.to_json)

          children = [] of Gtk::Widget
          index = UInt32.new(0)

          while item = box.observe_children.item(index)
            children.push(item.as(Gtk::Widget))
            index += 1
          end

          children = children.map { |child| child.name }
          state["children"] = JSON.parse(children.to_json)

          if parent = box.parent
            state["parent"] = JSON::Any.new(parent.name)
          else
            state["parent"] = JSON::Any.new(nil)
          end

          state["receivesDefault"] = JSON::Any.new(box.receives_default)
          state["scaleFactor"] = JSON::Any.new(box.scale_factor.to_i64)
          state["sensitive"] = JSON::Any.new(box.sensitive)
          state["spacing"] = JSON::Any.new(box.spacing.to_i64)
          state["tooltipMarkup"] = JSON::Any.new(box.tooltip_markup)
          state["tooltipText"] = JSON::Any.new(box.tooltip_text)
          state["verticalExpand"] = JSON::Any.new(box.vexpand)
          state["verticalExpandSet"] = JSON::Any.new(box.vexpand_set)
          state["visible"] = JSON::Any.new(box.visible)
          state["widthRequest"] = JSON::Any.new(box.width_request.to_i64)
        end
      when "Button"
        button = component.widget.as(Gtk::Button)

        component.state do |state|
          state["horizontalAlignment"] = JSON.parse({"id" => button.halign.to_i, "name" => button.halign.to_s}.to_json)
          state["verticalAlignment"] = JSON.parse({"id" => button.valign.to_i, "name" => button.valign.to_s}.to_json)
          state["accessibleRole"] = JSON.parse({"id" => button.accessible_role.to_i, "name" => button.accessible_role.to_s}.to_json)
          state["canFocus"] = JSON::Any.new(button.can_focus)
          state["canTarget"] = JSON::Any.new(button.can_target)
          state["cssClasses"] = JSON.parse(button.css_classes.to_json)
          state["cssName"] = JSON::Any.new(button.css_name)
          state["focusOnClick"] = JSON::Any.new(button.focus_on_click)
          state["focusable"] = JSON::Any.new(button.focusable)
          state["hasDefault"] = JSON::Any.new(button.has_default)
          state["hasFocus"] = JSON::Any.new(button.has_focus)
          state["hasTooltip"] = JSON::Any.new(button.has_tooltip)
          state["heightRequest"] = JSON::Any.new(button.height_request.to_i64)
          state["horizontalExpand"] = JSON::Any.new(button.hexpand)
          state["horizontalExpandSet"] = JSON::Any.new(button.hexpand_set)
          state["marginBottom"] = JSON::Any.new(button.margin_bottom.to_i64)
          state["marginEnd"] = JSON::Any.new(button.margin_end.to_i64)
          state["marginStart"] = JSON::Any.new(button.margin_start.to_i64)
          state["marginTop"] = JSON::Any.new(button.margin_top.to_i64)
          state["name"] = JSON::Any.new(button.name)
          state["opacity"] = JSON::Any.new(button.opacity)
          state["overflow"] = JSON.parse({"id" => button.overflow.to_i, "name" => button.overflow.to_s}.to_json)

          if parent = button.parent
            state["parent"] = JSON::Any.new(parent.name)
          else
            state["parent"] = JSON::Any.new(nil)
          end

          state["receivesDefault"] = JSON::Any.new(button.receives_default)
          state["scaleFactor"] = JSON::Any.new(button.scale_factor.to_i64)
          state["sensitive"] = JSON::Any.new(button.sensitive)
          state["tooltipMarkup"] = JSON::Any.new(button.tooltip_markup)
          state["tooltipText"] = JSON::Any.new(button.tooltip_text)
          state["verticalExpand"] = JSON::Any.new(button.vexpand)
          state["verticalExpandSet"] = JSON::Any.new(button.vexpand_set)
          state["visible"] = JSON::Any.new(button.visible)
          state["widthRequest"] = JSON::Any.new(button.width_request.to_i64)

          state["actionName"] = JSON::Any.new(button.action_name)

          # if child = button.child
          #   state["child"] = JSON::Any.new(child.name)
          # end

          state["iconName"] = JSON::Any.new(button.icon_name)
          state["label"] = JSON::Any.new(button.label)
          state["useUnderline"] = JSON::Any.new(button.use_underline)
        end
      when "Entry"
      when "Frame"
      when "Image"
      when "Label"
        label = component.widget.as(Gtk::Label)

        component.state do |state|
          state["horizontalAlignment"] = JSON.parse({"id" => label.halign.to_i, "name" => label.halign.to_s}.to_json)
          state["verticalAlignment"] = JSON.parse({"id" => label.valign.to_i, "name" => label.valign.to_s}.to_json)
          state["accessibleRole"] = JSON.parse({"id" => label.accessible_role.to_i, "name" => label.accessible_role.to_s}.to_json)
          state["canFocus"] = JSON::Any.new(label.can_focus)
          state["canTarget"] = JSON::Any.new(label.can_target)
          state["cssClasses"] = JSON.parse(label.css_classes.to_json)
          state["cssName"] = JSON::Any.new(label.css_name)
          state["focusOnClick"] = JSON::Any.new(label.focus_on_click)
          state["focusable"] = JSON::Any.new(label.focusable)
          state["hasDefault"] = JSON::Any.new(label.has_default)
          state["hasFocus"] = JSON::Any.new(label.has_focus)
          state["hasTooltip"] = JSON::Any.new(label.has_tooltip)
          state["heightRequest"] = JSON::Any.new(label.height_request.to_i64)
          state["horizontalExpand"] = JSON::Any.new(label.hexpand)
          state["horizontalExpandSet"] = JSON::Any.new(label.hexpand_set)
          state["marginBottom"] = JSON::Any.new(label.margin_bottom.to_i64)
          state["marginEnd"] = JSON::Any.new(label.margin_end.to_i64)
          state["marginStart"] = JSON::Any.new(label.margin_start.to_i64)
          state["marginTop"] = JSON::Any.new(label.margin_top.to_i64)
          state["name"] = JSON::Any.new(label.name)
          state["opacity"] = JSON::Any.new(label.opacity)
          state["overflow"] = JSON.parse({"id" => label.overflow.to_i, "name" => label.overflow.to_s}.to_json)

          if parent = label.parent
            state["parent"] = JSON::Any.new(parent.name)
          else
            state["parent"] = JSON::Any.new(nil)
          end

          state["receivesDefault"] = JSON::Any.new(label.receives_default)
          state["scaleFactor"] = JSON::Any.new(label.scale_factor.to_i64)
          state["sensitive"] = JSON::Any.new(label.sensitive)
          state["tooltipMarkup"] = JSON::Any.new(label.tooltip_markup)
          state["tooltipText"] = JSON::Any.new(label.tooltip_text)
          state["verticalExpand"] = JSON::Any.new(label.vexpand)
          state["verticalExpandSet"] = JSON::Any.new(label.vexpand_set)
          state["visible"] = JSON::Any.new(label.visible)
          state["widthRequest"] = JSON::Any.new(label.width_request.to_i64)

          state["ellipsize"] = JSON.parse({"id" => label.ellipsize.to_i, "name" => label.ellipsize.to_s}.to_json)
          state["justify"] = JSON.parse({"id" => label.justify.to_i, "name" => label.justify.to_s}.to_json)
          state["label"] = JSON::Any.new(label.label)
          state["lines"] = JSON::Any.new(label.lines.to_i64)
          state["label"] = JSON::Any.new(label.label)
          state["maxWidthCharacters"] = JSON::Any.new(label.max_width_chars.to_i64)

          if mnemonic_widget = label.mnemonic_widget
            state["mnemonicWidget"] = JSON::Any.new(mnemonic_widget.name)
          else
            state["mnemonicWidget"] = JSON::Any.new(nil)
          end

          state["naturalWrapMode"] = JSON.parse({"id" => label.natural_wrap_mode.to_i, "name" => label.natural_wrap_mode.to_s}.to_json)
          state["selectable"] = JSON::Any.new(label.selectable)
          state["singleLineMode"] = JSON::Any.new(label.single_line_mode)
          state["useUnderline"] = JSON::Any.new(label.use_underline)
          state["widthCharacters"] = JSON::Any.new(label.width_chars.to_i64)
          state["wrap"] = JSON::Any.new(label.wrap)
          state["wrapMode"] = JSON.parse({"id" => label.wrap_mode.to_i, "name" => label.wrap_mode.to_s}.to_json)
          state["xAlign"] = JSON::Any.new(label.xalign)
          state["yAlign"] = JSON::Any.new(label.yalign)
        end
      when "ListBox"
      when "ScrolledWindow"
      when "Switch"
      when "Tab"
      when "TextView"
      when "Window"
        window = component.widget.as(Gtk::ApplicationWindow)

        component.state do |state|
          # TODO: Add these state components
          # application
          # decorated
          # default_height
          # default_widget
          # default_width
          # deletable
          # destroy_with_parent
          # display
          # fullscreened
          # handle_menubar_accel
          # has_default
          # has_focus
          # hide_on_close
          # icon_name
          # is_active
          # layout_manager
          # maximized
          # mnemonics_visible
          # modal
          # receives_default
          # resizable
          # show_menubar
          # startup_id
          # title
          # titlebar
          # transient_for

          state["horizontalAlignment"] = JSON.parse({"id" => window.halign.to_i, "name" => window.halign.to_s}.to_json)
          state["verticalAlignment"] = JSON.parse({"id" => window.valign.to_i, "name" => window.valign.to_s}.to_json)
          state["accessibleRole"] = JSON.parse({"id" => window.accessible_role.to_i, "name" => window.accessible_role.to_s}.to_json)
          state["canFocus"] = JSON::Any.new(window.can_focus)
          state["canTarget"] = JSON::Any.new(window.can_target)
          state["cssClasses"] = JSON.parse(window.css_classes.to_json)
          state["cssName"] = JSON::Any.new(window.css_name)
          state["focusOnClick"] = JSON::Any.new(window.focus_on_click)
          state["focusable"] = JSON::Any.new(window.focusable)
          state["hasDefault"] = JSON::Any.new(window.has_default)
          state["hasFocus"] = JSON::Any.new(window.has_focus)
          state["hasTooltip"] = JSON::Any.new(window.has_tooltip)
          state["heightRequest"] = JSON::Any.new(window.height_request.to_i64)
          state["horizontalExpand"] = JSON::Any.new(window.hexpand)
          state["horizontalExpandSet"] = JSON::Any.new(window.hexpand_set)
          state["marginBottom"] = JSON::Any.new(window.margin_bottom.to_i64)
          state["marginEnd"] = JSON::Any.new(window.margin_end.to_i64)
          state["marginStart"] = JSON::Any.new(window.margin_start.to_i64)
          state["marginTop"] = JSON::Any.new(window.margin_top.to_i64)
          state["name"] = JSON::Any.new(window.name)
          state["opacity"] = JSON::Any.new(window.opacity)
          state["overflow"] = JSON.parse({"id" => window.overflow.to_i, "name" => window.overflow.to_s}.to_json)

          # TODO: Fix child casting
          # children = [] of Gtk::Widget
          # index = UInt32.new(0)

          # while item = window.observe_children.item(index)
          #   children.push(item.as(Gtk::Widget))
          #   index += 1
          # end

          # children = children.map { |child| child.name }
          # state["children"] = JSON.parse(children.to_json)

          if parent = window.parent
            state["parent"] = JSON::Any.new(parent.name)
          else
            state["parent"] = JSON::Any.new(nil)
          end

          state["receivesDefault"] = JSON::Any.new(window.receives_default)
          state["scaleFactor"] = JSON::Any.new(window.scale_factor.to_i64)
          state["sensitive"] = JSON::Any.new(window.sensitive)
          state["tooltipMarkup"] = JSON::Any.new(window.tooltip_markup)
          state["tooltipText"] = JSON::Any.new(window.tooltip_text)
          state["verticalExpand"] = JSON::Any.new(window.vexpand)
          state["verticalExpandSet"] = JSON::Any.new(window.vexpand_set)
          state["visible"] = JSON::Any.new(window.visible)
          state["widthRequest"] = JSON::Any.new(window.width_request.to_i64)

          state["title"] = JSON::Any.new(window.title)
          state["maximized"] = JSON::Any.new(window.maximized?)
          state["minimized"] = JSON::Any.new(nil)
        end
      end
    end

    def register(component : Haki::Component)
      component.properties do |properties|
        properties["motionNotify"] = JSON::Any.new("function() {}")
        properties["focusChange"] = JSON::Any.new("function() {}")

        properties["onPress"] = JSON::Any.new("function() {}")
        properties["onRelease"] = JSON::Any.new("function() {}")

        properties["onKeyPress"] = JSON::Any.new("function() {}")
      end

      registered_components[component.id] = component
    end

    def unregister(id : String)
      registered_components.delete(id)
    end
  end
end
