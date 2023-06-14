module Haki
  module Attributes
    class Base
      include JSON::Serializable

      @[JSON::Field(key: "id")]
      property id : String

      @[JSON::Field(key: "className")]
      property class_name : String = Helpers::Randomizer.random_string

      @[JSON::Field(key: "horizontalAlignment")]
      property horizontal_alignment : Gtk::Align = Gtk::Align::Baseline

      @[JSON::Field(key: "verticalAlignment")]
      property vertical_alignment : Gtk::Align = Gtk::Align::Baseline

      @[JSON::Field(key: "orientation")]
      property orientation : Gtk::Orientation = Gtk::Orientation::Vertical
    end
  end
end
