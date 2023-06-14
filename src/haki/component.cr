module Haki
  class Component
    getter id : String = String.new
    getter class_name : String = String.new
    getter kind : String = String.new

    property widget : Gtk::Widget

    properties : Helpers::Synchronized(Hash(String, JSON::Any)) = Helpers::Synchronized(Hash(String, JSON::Any)).new
    state : Helpers::Synchronized(Hash(String, JSON::Any)) = Helpers::Synchronized(Hash(String, JSON::Any)).new

    property_history : Helpers::Synchronized(Array(String))
    state_history : Helpers::Synchronized(Array(String))

    def initialize(@id : String, class_name : String, @kind : String, @widget : Gtk::Widget)
      @properties = Helpers::Synchronized(Hash(String, JSON::Any)).new
      @state = Helpers::Synchronized(Hash(String, JSON::Any)).new

      @property_history = Helpers::Synchronized(Array(String)).new
      @state_history = Helpers::Synchronized(Array(String)).new

      @property_history.push(@properties.to_json)
      @state_history.push(@state.to_json)

      case kind
      when "Box"
        index = JavaScript::Engine.instance.sandbox.push_object
        box = @widget.as(Gtk::Box)

        JavaScript::Engine.instance.sandbox.put_global_string(id)
      when "Button"
        index = JavaScript::Engine.instance.sandbox.push_object
        button = @widget.as(Gtk::Button)

        set_label = ->(argument : JSON::Any) {
          self.state do |state|
            state["label"] = argument
          end

          button.label = argument.to_s
          argument
        }

        register_callback("setLabel", 1, set_label)

        JavaScript::Engine.instance.sandbox.put_global_string(id)
      when "Entry"
      when "Frame"
      when "Image"
      when "Label"
        index = JavaScript::Engine.instance.sandbox.push_object
        label = @widget.as(Gtk::Label)

        # set_current_uri = ->(argument : JSON::Any) { widget.current_uri = argument.to_s; JSON::Any.new(widget.current_uri) }
        set_ellipsize = ->(argument : JSON::Any) {
          ellipsize_mode = Pango::EllipsizeMode.parse(argument.to_s)

          self.state do |state|
            state["ellipsize"] = JSON.parse({"id" => ellipsize_mode.to_i, "name" => ellipsize_mode.to_s}.to_json)
          end

          label.ellipsize = ellipsize_mode
          argument
        }

        set_justify = ->(argument : JSON::Any) {
          justification = Gtk::Justification.parse(argument.to_s)

          self.state do |state|
            state["justify"] = JSON.parse({"id" => justification.to_i, "name" => justification.to_s}.to_json)
          end

          label.justify = justification
          argument
        }

        set_label = ->(argument : JSON::Any) {
          self.state do |state|
            state["label"] = argument
          end

          label.label = argument.to_s
          argument
        }

        set_lines = ->(argument : JSON::Any) {
          self.state do |state|
            state["lines"] = argument
          end

          label.lines = argument.as_i
          argument
        }

        set_max_width_chars = ->(argument : JSON::Any) {
          self.state do |state|
            state["maxWidthCharacters"] = argument
          end

          label.max_width_chars = argument.as_i
          argument
        }

        # set_mnemonic_keyval = ->(argument : JSON::Any) { label.mnemonic_keyval = argument.as_i; JSON::Any.new(label.mnemonic_keyval.to_i64) }
        set_natural_wrap_mode = ->(argument : JSON::Any) {
          natural_wrap_mode = Gtk::NaturalWrapMode.parse(argument.to_s)

          self.state do |state|
            state["naturalWrapMode"] = JSON.parse({"id" => natural_wrap_mode.to_i, "name" => natural_wrap_mode.to_s}.to_json)
          end

          label.natural_wrap_mode = natural_wrap_mode
          argument
        }

        set_selectable = ->(argument : JSON::Any) {
          self.state do |state|
            state["selectable"] = argument
          end

          label.selectable = argument.as_bool
          argument
        }

        # set_has_selection_bounds = ->(argument : JSON::Any) { label.selection_bounds = argument.as_bool; JSON::Any.new(label.selection_bounds) }
        set_is_single_line_mode = ->(argument : JSON::Any) {
          self.state do |state|
            state["singleLineMode"] = argument
          end

          label.single_line_mode = argument.as_bool
        }

        set_text = ->(argument : JSON::Any) {
          self.state do |state|
            state["text"] = argument
          end

          label.text = argument.to_json
          argument
        }

        set_use_markup = ->(argument : JSON::Any) {
          self.state do |state|
            state["useMarkup"] = argument
          end

          label.use_markup = argument.as_bool
          argument
        }

        set_use_underline = ->(argument : JSON::Any) {
          self.state do |state|
            state["useUnderline"] = argument
          end

          label.use_underline = argument.as_bool
          argument
        }

        set_width_chars = ->(argument : JSON::Any) {
          self.state do |state|
            state["widthCharacter"] = argument
          end

          label.width_chars = argument.as_i
          argument
        }

        set_wrap = ->(argument : JSON::Any) {
          self.state do |state|
            state["wrap"] = argument
          end

          label.wrap = argument.as_bool
          argument
        }

        set_wrap_mode = ->(argument : JSON::Any) {
          wrap_mode = Pango::WrapMode.parse(argument.to_s)

          self.state do |state|
            state["wrapMode"] = JSON.parse({"id" => wrap_mode.to_i, "name" => wrap_mode.to_s}.to_json)
          end

          label.wrap_mode = wrap_mode
          argument
        }

        set_xalign = ->(argument : JSON::Any) {
          self.state do |state|
            state["xAlign"] = argument
          end

          label.xalign = argument.as_f32
          argument
        }

        set_yalign = ->(argument : JSON::Any) {
          self.state do |state|
            state["yAlign"] = argument
          end

          label.yalign = argument.as_f32
          argument
        }

        register_callback("setEllipsize", 1, set_ellipsize)
        register_callback("setJustify", 1, set_justify)
        register_callback("setLabel", 1, set_label)
        register_callback("setLines", 1, set_lines)
        register_callback("setMaxWidthChars", 1, set_max_width_chars)
        register_callback("setNaturalWrapMode", 1, set_natural_wrap_mode)
        register_callback("setIsSelectable", 1, set_selectable)
        register_callback("setIsSingleLineMode", 1, set_is_single_line_mode)
        register_callback("setText", 1, set_text)
        register_callback("setUseMarkup", 1, set_use_markup)
        register_callback("setUseUnderline", 1, set_use_underline)
        register_callback("setWidthChars", 1, set_width_chars)
        register_callback("setWrap", 1, set_wrap)
        register_callback("setWrapMode", 1, set_wrap_mode)
        register_callback("setXAlign", 1, set_xalign)
        register_callback("setYAlign", 1, set_yalign)

        JavaScript::Engine.instance.sandbox.put_global_string(id)
      when "ListBox"
      when "ScrolledWindow"
      when "Switch"
      when "Tab"
      when "TextView"
        raise "Not implemented"
      when "Window"
        index = JavaScript::Engine.instance.sandbox.push_object
        application_window = @widget.as(Gtk::ApplicationWindow)

        set_title = ->(argument : JSON::Any) {
          self.state do |state|
            state["title"] = argument
          end

          application_window.title = argument.to_s
          argument
        }

        maximize = ->(argument : JSON::Any) {
          self.state do |state|
            state["maximized"] = JSON::Any.new(true)
            state["minimized"] = JSON::Any.new(false)
          end

          application_window.maximize
          argument
        }
        minimize = ->(argument : JSON::Any) {
          self.state do |state|
            state["minimized"] = JSON::Any.new(true)
            state["maximized"] = JSON::Any.new(false)
          end

          application_window.minimize
          argument
        }

        register_callback("setTitle", 1, set_title)

        register_callback("maximize", 0, maximize)
        register_callback("minimize", 0, minimize)

        JavaScript::Engine.instance.sandbox.put_global_string(id)
      end

      source_code = [] of String

      source_code.push(["#{id}", ".", "isMounted", " ", "=", " ", "true", ";"].join)

      # Direct calls to the evaluation to make it a bit faster.
      JavaScript::Engine.instance.sandbox.eval_mutex! source_code.join

      # Initialize the id and the class_name for the component.
      update_component(:id, id) if should_component_update?(:id, id)
      update_component(:class_name, class_name) if should_component_update?(:class_name, class_name)
    end

    def id=(id)
      update_component(:id, id) if should_component_update?(:id, id)
    end

    def class_name=(class_name)
      update_component(:class_name, class_name) if should_component_update?(:class_name, class_name)
    end

    def properties
      yield @properties

      update_component(:properties, @properties) if should_component_update?

      @property_history.push(@properties.to_json)
      @property_history.delete_at(0)
    end

    def state
      yield @state

      update_component(:state, @state) if should_component_update?

      @state_history.push(@state.to_json)
      @state_history.delete_at(0)
    end

    private def should_component_update?
      @property_history.last != @properties.to_json || @state_history.last != @state.to_json
    end

    private def should_component_update?(symbol : Symbol, value : String)
      case symbol
      when :id
        @id != value
      when :class_name
        @class_name != value
      end
    end

    private def unmount
      source_code = [] of String

      # Direct calls to the evaluation to make it a bit faster.
      source_code.push(["#{id}", ".", "isMounted", " ", "=", " ", "false", ";"].join)
      JavaScript::Engine.instance.sandbox.eval_mutex! source_code.join

      source_code.clear

      yield

      # Direct calls to the evaluation to make it a bit faster.
      source_code.push(["#{id}", ".", "isMounted", " ", "=", " ", "true", ";"].join)
      JavaScript::Engine.instance.sandbox.eval_mutex! source_code.join
    end

    private def update_component(symbol : Symbol, value : String)
      unmount do
        source_code = [] of String

        case symbol
        when :id
          source_code.push(["const", " ", "#{value}", " ", "=", " ", "#{id}", ";"].join)
          source_code.push(["#{id}", " ", "=", " ", "undefined"].join)

          widget.name = value
          @id = value
        when :class_name
          source_code.push(["#{id}", ".", "className", " ", "=", " ", "\"", "#{value}", "\"", ";"].join)

          @class_name = value
        end

        # Direct calls to the evaluation to make it a bit faster.
        JavaScript::Engine.instance.sandbox.eval_mutex! source_code.join
      end
    end

    private def update_component(symbol : Symbol, value : Helpers::Synchronized(Hash(String, JSON::Any)))
      unmount do
        source_code = [] of String

        case symbol
        when :properties
          source_code.push(["#{id}", ".", "properties", " ", "=", " ", value.to_json.gsub("\"", ""), ";"].join)

          @properties = value
        when :state
          source_code.push(["#{id}", ".", "state", " ", "=", " ", value.to_json, ";"].join)

          @state = value
        end

        # Direct calls to the evaluation to make it a bit faster.
        JavaScript::Engine.instance.sandbox.eval_mutex! source_code.join
      end
    end

    macro register_callback(function_name, argument_size, callback)
      JavaScript::Engine.instance.sandbox.push_string({{function_name}})

      LibDUK.push_c_function(JavaScript::Engine.instance.sandbox.ctx, ->(pointer : Pointer(Void)) {
        env = ::Duktape::Sandbox.new(pointer)

        # Get the component to identify by id.
        env.push_current_function
        env.get_prop_string(-1, "id")
        component_id = env.get_string(-1)

        # Get the closure to call the crystal code form JS
        env.push_current_function
        env.get_prop_string(-1, {{function_name}})

        callable = ::Box(Proc(JSON::Any, JSON::Any)).unbox(env.get_pointer(-1))
        argument_size = {{argument_size}}

        encoded_data = env.json_encode(0) if argument_size != 0
        argument = JSON.parse(encoded_data) if encoded_data

        begin
          if argument
            return_value = callable.call(argument)
          else
            return_value = callable.call(JSON::Any.new(nil))
          end

          Registry.instance.refresh_state(component_id.to_s)

          case return_value
          when return_value.as_a?
            # TODO: Add the Array push for array return types.
            env.call_success
          when return_value.as_bool?
            env.push_boolean(return_value.as_bool)
            env.call_success
          when return_value.as_f?
            env.push_number(return_value.as_f)
            env.call_success
          when return_value.as_h?
            # TODO: Add the Hash push for hash return types.
            env.call_success
          when return_value.as_i?
            env.push_int(return_value.as_i)
            env.call_success
          when return_value.as_s?
            env.push_string(return_value.as_s)
            env.call_success
          else
            env.push_null
            env.call_success
          end
        rescue exception
          Log.debug(exception: exception) { }

          env.call_failure
        end
      }, {{argument_size}})

      JavaScript::Engine.instance.sandbox.push_pointer(::Box.box({{callback}}))
      JavaScript::Engine.instance.sandbox.put_prop_string(-2, {{function_name}})

      JavaScript::Engine.instance.sandbox.push_string(id)
      JavaScript::Engine.instance.sandbox.put_prop_string(-2, "id")

      JavaScript::Engine.instance.sandbox.put_prop(index)
    end
  end
end
