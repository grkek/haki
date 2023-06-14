module Haki
  module Attributes
    class Container
      include JSON::Serializable

      @[JSON::Field(key: "containerLabel")]
      property container_label : String?

      @[JSON::Field(key: "expand")]
      property? expand : Bool = false

      @[JSON::Field(key: "fill")]
      property? fill : Bool = false

      @[JSON::Field(key: "padding")]
      property padding : Int32 = 0
    end
  end
end
