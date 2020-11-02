require "../spec_helper"

describe Layout::Dom::ElementNode do
  describe "#to_html" do
    it "generates an html representation of Dom tree including this node" do
      node = Layout::Dom::ElementNode.new("div", {"class" => "class-name", "id" => "my-id"}, [
        Layout::Dom::TextNode.new("Words"),
        Layout::Dom::ElementNode.new("input", {"type" => "text", "placeholder" => "...", "name" => "text-input"}),
      ])

      node.to_html.should eq("<div class='class-name' id='my-id'>Words<input type='text' placeholder='...' name='text-input'></input></div>")
    end
  end
end
