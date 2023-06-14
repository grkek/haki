require "../src/haki"

GC.disable

Log.setup(:info)

puts "JavaScript engine running at: #{Haki::JavaScript::Engine.instance.path}"

builder = Haki::Builder.new
builder.build_from_file(file: "#{__DIR__}/dist/index.html")
