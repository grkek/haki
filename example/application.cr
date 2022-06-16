require "../src/haki"

builder = Haki::Builder.new
builder.build_from_document(document: "#{__DIR__}/dist/index.html")
