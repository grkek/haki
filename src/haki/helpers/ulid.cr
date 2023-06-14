module Haki
  module Helpers
    module ULID
      extend self

      # Crockford's Base32
      private ENCODING     = "ABCDEFGHJKMNPQRSTVWXYZ"
      private ENCODING_LEN = ENCODING.size
      private TIME_LEN     = 10
      private RANDOM_LEN   = 16

      # Generate a ULID
      #
      # ```
      # Helpers::ULID.generate
      # # => "01B3EAF48P97R8MP9WS6MHDTZ3"
      # ```
      def generate(seed_time : Time = Time.utc) : String
        encode_time(seed_time, TIME_LEN) + encode_random(RANDOM_LEN)
      end

      private def encode_time(now : Time, len : Int32) : String
        ms = now.to_unix_ms

        String.build do |io|
          len.times do |_i|
            mod = ms % ENCODING_LEN
            io << ENCODING[mod.to_i]
            ms = (ms - mod) / ENCODING_LEN
          end
        end.reverse
      end

      private def encode_random(len : Int32) : String
        String.build do |io|
          len.times do |_i|
            rand = Random.rand(ENCODING_LEN)
            io << ENCODING[rand]
          end
        end.reverse
      end
    end
  end
end
