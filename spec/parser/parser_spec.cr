require "../spec_helper"

describe Layout::Parser do
  describe ".parse" do
    it "parses provided subset of HTML" do
      document = Layout::Parser.parse("<div class='class-name' id='my-id'><input type='text' placeholder='...' name='text-input'></input></div>")
      document.to_html.should eq("<div class='class-name' id='my-id'><input type='text' placeholder='...' name='text-input'></input></div>")
    end
  end
end
