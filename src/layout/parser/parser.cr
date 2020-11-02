require "./tokenizer"

module Layout
  module Parser
    def self.parse(text : String) : Layout::Dom::Node
      if text.size < 1
        raise Exceptions::EmptyComponentException.new
      end

      tokenizer = Layout::Parser::Tokenizer.new(text)
      nodes = tokenizer.parse_nodes
      nodes.first
    end
  end
end
