require 'byebug'
require 'classes/bm_type'
require 'classes/bm_shape'
require 'classes/bm_chunk'
require 'mixins/helpers'

module Bytemapper
  module Mapper
    BM_Type = ::Bytemapper::Classes::BM_Type
    BM_Shape = ::Bytemapper::Classes::BM_Shape
    BM_Chunk = ::Bytemapper::Classes::BM_Chunk

    BasicTypes = {
     uint8_t: [8,'C'],
     uint16_t: [16,'S'],
     uint32_t: [32,'L'],
     uint64_t: [64,'Q'],
     int8_t:  [8,'c'],
     int16_t: [16,'s'],
     int32_t: [32,'l'],
     int64_t: [64,'q'],
     bool: [8,'C']
    }

    def self.included(klass)
      klass.instance_eval do
        BasicTypes.each { |name, obj| BM_Type.wrap(obj, name) }
      end
    end

    def register_type(obj, name)
      BM_Type.wrap(obj, name)
    end
    
    def wrap(obj, name)
      byebug
      BM_Shape.wrap(obj, name)
    end

    def map(bytes, shape, name = nil, endian = nil) 
      bytes = format_bytes(bytes)
      return BM_Chunk.new(bytes, shape, endian) if shape.is_a?(BM_Shape)
      raise ArgumentError.new("Invalid shape definition, '#{shape}'") unless shape.is_a?(Hash) || shape.is_a?(Symbol) || shape.is_a?(String)
      name = shape if name.nil? && shape.is_a?(String) || shape.is_a?(Symbol)
      shape = BM_Shape.wrap(shape, name)
      BM_Chunk.new(bytes, shape, endian)

    end 

    def format_bytes(bytes)
      if Mixins::Helpers.is_filelike?(bytes)
         raise ArgumentError("Mapping directly from file not supported; read the bytes first")
      elsif Mixins::Helpers.is_stringiolike?(bytes)
        bytes = bytes.string
      end
      bytes = bytes.force_encoding(Encoding::ASCII_8BIT) unless bytes.encoding == Encoding::ASCII_8BIT
      StringIO.new(bytes)
    end
  end
end
