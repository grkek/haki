module Haki
  module JavaScript
    module Message
      struct Request
        include JSON::Serializable

        @[JSON::Field(key: "id")]
        property id : String

        @[JSON::Field(key: "directory")]
        property directory : String

        @[JSON::Field(key: "file")]
        property file : String

        @[JSON::Field(key: "line")]
        property line : Int32

        @[JSON::Field(key: "processing")]
        property processing : Processing

        @[JSON::Field(key: "eventName")]
        property event_name : String

        @[JSON::Field(key: "sourceCode")]
        property source_code : String

        def initialize(@id : String, @directory : String, @file : String, @line : Int32, @processing : Processing, event_name : String?, source_code : String?)
          @source_code = source_code || "/* It is hard to think when my mind goes blank, */"
          @event_name = event_name || "/* You just can't think when your mind goes blank. */"
        end
      end
    end
  end
end
