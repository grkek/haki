require "./module"

module Haki
  module JavaScript
    module StandardLibrary
      class Minuscule < Module
        property sandbox : Duktape::Sandbox

        def initialize(@sandbox : Duktape::Sandbox)
          @sandbox.eval_mutex! "std.minuscule = {};"
        end

        def name : String
          "Minuscule"
        end

        def module_name : String
          "minuscule"
        end

        def description : String
          "Minuscule module allows the user to use helpers."
        end

        def definitions : Array(Definition)
          @sandbox.push_global_proc("stdMinusculeUuid", 1) do |ptr|
            env = ::Duktape::Sandbox.new(ptr)

            env.push_string(UUID.random.to_s)
            env.call_success
          end

          @sandbox.eval_mutex! <<-JS
            std.minuscule.uuid = function() { return stdMinusculeUuid(); };
          JS

          [] of Definition
        end
      end
    end
  end
end
