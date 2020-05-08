module ByteMapper

  # Type the standard fixed widths with their unpack directive
  module Basics
    def self.included(klass)
      @
      klass.class_eval do 
        {
            int8_t: [8,'c'],
           int16_t: [16,'s'],
           int32_t: [32,'l'],
           int64_t: [64,'q'],
           uint8_t: [8,'C'],
          uint16_t: [16,'S'],
          uint32_t: [32,'L'],
          uint64_t: [64,'Q']
        }.each do |name, type|

        end
      end
    end
  end
end
