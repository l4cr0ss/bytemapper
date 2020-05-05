require 'shapes'

module ByteMapper
  module Mapper
    include Shapes

    def self.map(name_or_shape, bytes, endian = nil)
      shape = name_or_shape.class == BM_Shape ? name_or_shape : Shapes.find(name_or_shape.to_sym)
      BM_Chunk.new(shape, bytes, endian)
    end

    class BM_Chunk
      attr_reader :shape, :bytes, :endian

      def initialize(shape, bytes, endian)
        @shape = shape
        @bytes = bytes
        @endian = endian
        _map(shape)
      end

      private

      def _map(shape)
        shape.each do |k,v|
          singleton_class.instance_eval { attr_reader k } unless singleton_class.method_defined? k
          if v.is_a? ::ByteMapper::BM_Shape
            _map(v) 
          else
            instance_variable_set("@#{k.to_s}", _unpack(v))
          end
        end
      end

      def _unpack(value)
        num_bytes, flag = value
        bytes.read(num_bytes >> 3).unpack("#{flag}#{endian}")[0]
      end
    end
  end
end
