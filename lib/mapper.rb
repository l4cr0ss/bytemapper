require 'classes/bm_registrar'
require 'classes/bm_shape'
require 'classes/bm_type'

module ByteMapper
  module Mapper
    extend ::ByteMapper::Mixins::Helpers

    def register_types(obj)
      obj.each { |name,obj| register_type(obj, name) }
    end

    def register_shapes(obj)
      obj.each { |name,obj| register_shape(obj, name) }
    end

    def register_type(obj, name = nil)
      obj = ::ByteMapper::Classes::BM_Type.wrap(obj, name)
      ByteMapper::Classes::BM_Registrar.instance.register(obj)
    end

    def register_shape(obj, name = nil)
      obj = ::ByteMapper::Classes::BM_Shape.wrap(obj, name)
      obj.name = name
      ByteMapper::Classes::BM_Registrar.instance.register(obj)
    end

    def retrieve(obj, klass)
      ByteMapper::Classes::BM_Registrar.instance.retrieve(obj, klass)
    end

    def map(obj, bytes, endian = nil)
      shape = retrieve(obj, ::ByteMapper::Classes::BM_Shape)
      bytes = format_bytes(bytes)
      ::ByteMapper::Classes::BM_Chunk.new(shape, bytes, endian)
    end

    def format_bytes(bytes)
      if is_filelike?(bytes)
        err = "Mapping directly from file not supported - bytes must be string-like"
      elsif is_stringiolike?(bytes)
        bytes = bytes.string
      end
      bytes = bytes.force_encoding(Encoding::ASCII_8BIT) unless bytes.encoding == ENCODING::ASCII_8BIT
    end
  end
end
