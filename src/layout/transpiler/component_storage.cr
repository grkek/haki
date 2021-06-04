module Layout
  module Transpiler
    class ComponentStorage
      INSTANCE = new

      private property applications : Hash(String, Gtk::Application)
      private property components : Hash(String, Pointer(LibGtk::Widget))

      def initialize
        @applications = {} of String => Gtk::Application
        @components = {} of String => Pointer(LibGtk::Widget)
      end

      def store(cid : String, widget : Gtk::Widget)
        @components[cid] = widget.as(Pointer(LibGtk::Widget))
      end

      def retrieve(cid : String) : Pointer(LibGtk::Widget)
        if widget = @components[cid]?
          return widget.not_nil!
        else
          raise Exceptions::ComponentNotFoundException.new(cid)
        end
      end

      def components : Array(String)
        @components.keys
      end

      def applications : Array(String)
        @applications.keys
      end

      def store_application(cid : String, application : Gtk::Application)
        @applications[cid] = application
      end

      def retrieve_application(cid : String) : Gtk::Application
        @applications[cid]
      end
    end
  end
end
