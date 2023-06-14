module Haki
  class Builder
    include Elements

    property socket : UNIXSocket = UNIXSocket.new(JavaScript::Engine.instance.path)
    property scripts : Array(String) = [] of String

    # Create the main application, initialize the JavaScript context and build the components.
    def build_from_string(string : String)
      if string.size < 1
        raise Exceptions::EmptyComponentException.new
      end

      tokenizer = Parser::Tokenizer.new(string)
      nodes = tokenizer.parse_nodes

      case nodes.first
      when Application
        application = Gtk::Application.new(application_id: nodes.first.as(Generic).attributes["applicationId"]?.to_s || ["com", "haki", UUID.random.hexstring].join("."))

        application.activate_signal.connect do
          build_components(nodes.first, application)

          elements = nodes.first.children.reject! do |child|
            child.kind != "Window"
          end

          child = elements.first.as(Window)

          window = child.build_widget(application)
          transpile_components(child, window)

          @scripts.each do |script|
            request = JavaScript::Message::Request.new(
              id: window.name,
              directory: __DIR__,
              file: __FILE__,
              line: __LINE__,
              processing: JavaScript::Message::Processing::RAW,
              event_name: nil,
              source_code: script)

            socket.puts(request.to_json)
          end

          window.try(&.show)
        end

        # Start the idle garbage collector.
        IdleGC.start
        application.run
      else
        raise "The first component must always be an `<Application></Application>`."
      end
    end

    def build_from_file(file)
      File.open(file) do |fp|
        string = fp.gets_to_end

        build_from_string(string)
      end
    end

    # Run the initalize_component method for each child and receive an actual Gtk::Widget from it
    # then either containerize it if it is a container or just return the transpiled component.
    private def transpile_component(child, widget : Gtk::Widget)
      case child
      when Box, Frame, Tab, ListBox, ScrolledWindow
        container = child.build_widget(widget)

        child.children.each do |subchild|
          transpile_component(subchild, container)
        end
      when Button, Label, Entry, HorizontalSeparator, VerticalSeparator, Switch
        child.build_widget(widget)
      when Script
        if path = child.attributes["src"]?
          file = File.open(path.to_s).gets_to_end
          @scripts.push(file)
        end

        if child.children.size != 0
          case child
          when Text
            @scripts.push(child.data)
          end
        end
      when Export
        child.children.each do |subchild|
          transpile_component(subchild, widget)
        end
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

      if child.children.size != 0
        first_child = child.children.first

        case first_child
        when Text
          css_provider.load_from_data(first_child.content.bytes)
        end
      end

      if path = child.attributes["src"]?
        css_provider.load_from_path(path.to_s)
      end

      if display = Gdk::Display.default
        Gtk::StyleContext.add_provider_for_display(display, css_provider, Gtk::STYLE_PROVIDER_PRIORITY_APPLICATION.to_u32)
      end
    end

    # Build components from the main document model, start with either a StyleSheet component or the Window component.
    private def build_components(document, widget)
      document.children.each do |child|
        case child
        when StyleSheet
          process_stylesheet(child)
        when Script
          if path = child.attributes["src"]?
            file = File.open(path.to_s).gets_to_end
            @scripts.push(file)
          end

          if child.children.size != 0
            first_child = child.children.first

            case first_child
            when Text
              @scripts.push(first_child.content)
            end
          end
        end
      end
    end
  end
end
