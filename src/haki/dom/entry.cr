require "./node"
require "./element"

module Haki
  module Dom
    class TextInput < Element
      @attributes : Hash(String, String)

      getter :attributes

      def initialize(@attributes)
        @kind = "TextInput"
        @children = [] of Node
        substitution()
      end

      def initialize_component(widget : Gtk::Widget)
        id = @attributes["id"]? || ""
        class_name = @attributes["className"]? || nil
        label = @attributes["value"]? || nil
        placeholder = @attributes["placeholder"]? || nil

        horizontal_align = to_align(@attributes["horizontalAlign"]? || "")
        vertical_align = to_align(@attributes["verticalAlign"]? || "")

        password_char = @attributes["passwordCharacter"]? || nil
        visibility = to_bool(@attributes["isPassword"]? || "false") ? false : true
        invisible_char = password_char.try(&.bytes.first.to_u32)

        entry = Gtk::Entry.new(name: id, text: label, placeholder_text: placeholder, invisible_char: invisible_char, visibility: visibility, halign: horizontal_align, valign: vertical_align)

        Duktape::Engine.instance.eval! ["const", id, "=", {type: "Entry", className: class_name, avaliableCallbacks: ["onInsertedText", "onDeletedText", "onCutClipboard", "onCopyClipboard", "onPasteClipboard", "onActivate"]}.to_json].join(" ")

        entry.buffer.on_inserted_text do |buffer|
          Duktape::Engine.instance.eval! [id, ".", "onInsertedText", "(", "\"", buffer.text, "\"", ")"].join
        end

        entry.buffer.on_deleted_text do |buffer|
          Duktape::Engine.instance.eval! [id, ".", "onDeletedText", "(", "\"", buffer.text, "\"", ")"].join
        end

        entry.on_cut_clipboard do
          Duktape::Engine.instance.eval! [id, ".", "onCutClipboard", "(", "\"", entry.buffer.text, "\"", ")"].join
        end

        entry.on_copy_clipboard do
          Duktape::Engine.instance.eval! [id, ".", "onCopyClipboard", "(", "\"", entry.buffer.text, "\"", ")"].join
        end

        entry.on_paste_clipboard do
          Duktape::Engine.instance.eval! [id, ".", "onPasteClipboard", "(", "\"", entry.buffer.text, "\"", ")"].join
        end

        entry.on_activate do
          Duktape::Engine.instance.eval! [id, ".", "onActivate", "(", "\"", entry.buffer.text, "\"", ")"].join
        end

        box_expand = @attributes["boxExpand"]? || "false"
        box_fill = @attributes["boxFill"]? || "false"
        box_padding = @attributes["boxPadding"]? || "0"

        if box_padding.includes?(".0")
          box_padding = box_padding[..box_padding.size - 3]
        end

        entry.on_event_after do |_widget, event|
          case event.event_type
          when Gdk::EventType::MOTION_NOTIFY
            false
          else
            # TODO: Add an event handler for the components to forward information to JavaScript.
            true
          end
        end

        containerize(widget, entry, box_expand, box_fill, box_padding)
        add_class_to_css(entry, class_name)

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
