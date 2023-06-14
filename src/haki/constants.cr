module Haki
  module Constants
    ENVIRONMENT          = ENV["ENVIRONMENT"]? || "production"
    STATELESS_COMPONENTS = ["Export", "Import", "Script", "StyleSheet", "Text"]
  end
end
