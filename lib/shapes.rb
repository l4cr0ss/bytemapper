module ByteMapper
  module Shapes
    def self.register_shape(symbol, shape)
      const_set(symbol, shape) unless const_defined? symbol
    end

    def self.registered?(symbol)
      const_defined? symbol
    end
  end
end
