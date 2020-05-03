module ByteMapper

  # Type the standard sizes with their unpack directive
  module Types
    def self.register_type(name, type)
      const_set(name, type) unless const_defined? name
    end

    INT8_T 	= [8,'c']
    INT16_T	= [16,'s']
    INT32_T	= [32,'l']
    INT64_T	= [64,'q']
    UINT8_T 	= [8,'C']
    UINT16_T	= [16,'S']
    UINT32_T	= [32,'L']
    UINT64_T	= [64,'Q']
  end
end
