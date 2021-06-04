require "./node"

module Layout
  module Dom
    class Element < Node
      include JSON::Serializable
      @attributes : Hash(String, String)

      getter :attributes
      getter cid : String = UUID.random.hexstring

      def initialize(@kind, @attributes, @children = [] of Node)
        substitution()
      end

      def substitution
        @attributes.map do |key, value|
          matches = value.scan(/\${(.*?)}/)

          case matches.size
          when 0
            @attributes[key] = value
          else
            matches.each do |match|
              hash = match.to_h

              begin
                @attributes[key] = value.gsub(hash[0].not_nil!, Layout::Js::Engine::INSTANCE.evaluate("__std__value_of__(#{hash[1].not_nil!})").to_s)
              rescue ex : Exception
                @attributes[key] = value
                puts "An exception occured while evaluating a variable format routine: #{ex}"
              end
            end
          end
        end
      end

      def did_mount(cid)
        if function = @attributes["onComponentDidMount"]?
          Layout::Js::Engine::INSTANCE.evaluate("#{function}(#{@attributes.to_json}, getElementByComponentId(\"#{cid}\"))")
        end
      end

      def did_update(cid, event_type)
        if function = @attributes["onComponentDidUpdate"]?
          Layout::Js::Engine::INSTANCE.evaluate("#{function}(#{@attributes.to_json}, getElementByComponentId(\"#{cid}\"), \"#{event_type}\")")
        end
      end

      def will_unmount(cid)
        if function = @attributes["onComponentWillUnmount"]?
          Layout::Js::Engine::INSTANCE.evaluate("#{function}(#{@attributes.to_json}, getElementByComponentId(\"#{cid}\")")
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
          widget.insert(component, 1_000_000)
        when Gtk::ApplicationWindow
          widget.add(component)
        end
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
