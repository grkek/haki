module Duktape
  module API::Eval
    def eval_mutex
      flags = LibDUK::Compile.new(1_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoFilename

      @mutex.synchronize do
        LibDUK.eval_raw ctx, nil, 0, flags
      end
    end

    def eval_string_mutex(src : String)
      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::StrLen |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoFilename

      @mutex.synchronize do
        LibDUK.eval_raw ctx, src, 0, flags
      end
    end

    def eval_mutex!
      raise_error eval_mutex
    end

    def eval_mutex!(str : String)
      eval_string_mutex! str
    end

    def eval_string_mutex!(src : String)
      raise_error eval_string_mutex(src)
    end
  end
end
