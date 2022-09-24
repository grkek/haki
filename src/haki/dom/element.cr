require "./node"

module Haki
  module Dom
    class Element < Node
      include JSON::Serializable
      @attributes : Hash(String, String)

      getter :attributes

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
                @attributes[key] = value.gsub(hash[0].not_nil!, Duktape::Engine.instance.eval!("__std__value_of__(#{hash[1].not_nil!})").to_s)
              rescue ex : Exception
                @attributes[key] = value
                puts "An exception occured while evaluating a variable format routine: #{ex}"
              end
            end
          end
        end
      end

      private def to_align(str : String) : Gtk::Align
        case str
        when "fill"
          Gtk::Align::Fill
        when "start"
          Gtk::Align::Start
        when "end"
          Gtk::Align::End
        when "center"
          Gtk::Align::Center
        when "baseline"
          Gtk::Align::Baseline
        else
          Gtk::Align::Baseline
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
          expand = to_bool(box_expand)
          component.hexpand = expand
          component.vexpand = expand

          margin = box_padding.to_i
          component.margin_top = margin
          component.margin_bottom = margin
          component.margin_start = margin
          component.margin_end = margin

          widget.append(component)
        when Gtk::ScrolledWindow, Gtk::Frame
          widget.child = component
        when Gtk::ListBox
          widget.insert(component, 1_000_000)
        when Gtk::ApplicationWindow
          widget.child = component
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
