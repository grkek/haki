require "json"
require "duktape"
require "duktape/runtime"
require "gtk4"
require "uuid"
require "levenshtein"
require "colorize"
require "idle-gc"
require "baked_file_system"
require "non-blocking-spawn"
require "socket"

require "./haki/storage"
require "./haki/helpers/**"
require "./haki/attributes/**"
require "./haki/extensions/**"
require "./haki/exceptions/**"
require "./haki/javascript/**"
require "./haki/elements/**"
require "./haki/parser/**"
require "./haki/*"

module Haki
end
