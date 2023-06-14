require "../src/haki"

GC.disable

Log.setup(:info)

# You can connect to the JavaScript engine for debugging and as such.
puts "JavaScript engine running at: #{Haki::JavaScript::Engine.instance.path}"

builder = Haki::Builder.new
builder.build_from_file(file: "#{__DIR__}/dist/index.html")
