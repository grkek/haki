require "./tokenizer"

module Haki
  module Parser
    def self.parse(text : String) : Dom::Node
      if text.size < 1
        raise Exceptions::EmptyComponentException.new
      end

      tokenizer = Tokenizer.new(text)
      nodes = tokenizer.parse_nodes
      nodes.first
    end
  end
end
