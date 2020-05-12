require 'classes/bm_registry'
require 'classes/bm_type'
require 'classes/bm_shape'
require 'classes/bm_chunk'
require 'mixins/helpers'

module ByteMapper
  module Classes
    class Mapper
      include Mixins::Helpers

      def map(bytes, shape, endian = nil)
        # if you get a BM_Shape just use it to build the chunk
        return BM_Chunk.new(bytes, shape, endian) if shape.is_a?(BM_Shape) 

        # otherwise try and wrap it. if it fails you have to raise.
        wrapped = BM_Shape.wrap(shape)
        wrapped.nil? ? raise("Unable to map #{shape.class}; try wrapping it first") : wrapped
      end

      def format_bytes(bytes)
        if Helpers::is_filelike?(bytes)
           raise ArgumentError("Mapping directly from file not supported; read the bytes first")
        elsif Helpers::is_stringiolike?(bytes)
          bytes = bytes.string
        end
        bytes = bytes.force_encoding(Encoding::ASCII_8BIT) unless bytes.encoding == Encoding::ASCII_8BIT
      end


      # The only two classes that make sense for this call are BM_Type and
      # BM_Shape
      def valid_class?(klass)
        [BM_Shape, BM_Type].include?(klass)
      end
    end
  end
end
