require "./node"
require "./element"

module Layout
  module Dom
    class TextInput < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes)
        @kind = "TextInput"
        @children = [] of Node
        substitution()
      end

      def initialize_component(widget : Gtk::Widget, component_storage : Transpiler::ComponentStorage)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        label = @attributes["value"]? || nil
        placeholder = @attributes["placeholder"]? || nil
        text_changed = @attributes["onChangeText"]? || nil
        cut_clipboard = @attributes["onCut"]? || nil
        copy_clipboard = @attributes["onCopy"]? || nil
        paste_clipboard = @attributes["onPaste"]? || nil
        on_activate = @attributes["onActivate"]? || nil

        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        password_char = @attributes["passwordCharacter"]? || nil
        visibility = to_bool(@attributes["isPassword"]? || "false") ? false : true
        invisible_char = password_char.try(&.bytes.first.to_u32)

        entry = Gtk::Entry.new(name: id, text: label, placeholder_text: placeholder, invisible_char: invisible_char, visibility: visibility, halign: horizontal_align, valign: vertical_align)

        entry.buffer.on_inserted_text do |buffer|
          if text_changed
            Layout::Js::Engine::INSTANCE.evaluate("#{text_changed}(getElementByComponentId(\"#{@cid}\"), \"#{buffer.text}\")")
          end
        end

        entry.buffer.on_deleted_text do |buffer|
          if text_changed
            Layout::Js::Engine::INSTANCE.evaluate("#{text_changed}(getElementByComponentId(\"#{@cid}\"), \"#{buffer.text}\")")
          end
        end

        entry.on_cut_clipboard do
          if cut_clipboard
            Layout::Js::Engine::INSTANCE.evaluate("#{cut_clipboard}(getElementByComponentId(\"#{@cid}\"), \"#{entry.buffer.text}\")")
          end
        end

        entry.on_copy_clipboard do
          if copy_clipboard
            Layout::Js::Engine::INSTANCE.evaluate("#{copy_clipboard}(getElementByComponentId(\"#{@cid}\"), \"#{entry.buffer.text}\")")
          end
        end

        entry.on_paste_clipboard do
          if paste_clipboard
            Layout::Js::Engine::INSTANCE.evaluate("#{paste_clipboard}(getElementByComponentId(\"#{@cid}\"), \"#{entry.buffer.text}\")")
          end
        end

        entry.on_activate do
          if on_activate
            Layout::Js::Engine::INSTANCE.evaluate("#{on_activate}(getElementByComponentId(\"#{@cid}\"), \"#{entry.buffer.text}\")")
          end
        end

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        containerize(widget, entry, box_expand, box_fill, box_padding)

        entry.on_event_after do |widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            did_update(@cid, event.event_type.to_s)
            true
          end
        end

        add_class_to_css(entry, class_name)
        component_storage.store(id, entry)
        component_storage.store(@cid, entry)
        did_mount(@cid)

        entry
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
