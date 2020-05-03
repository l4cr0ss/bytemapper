module ByteMapper
  module Shapes
    def self.register_shape(symbol, shape)
      const_set(symbol, shape) unless const_defined? symbol
    end
  end
end
