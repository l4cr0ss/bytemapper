require 'singleton'
require 'classes/bm_registry'
require 'classes/bm_type'
require 'classes/bm_shape'
require 'classes/bm_chunk'
require 'mixins/helpers'

module ByteMapper
  module Classes
    class Mapper
      include Singleton
      include Mixins::Helpers


      def initialize()
      end

      def register_types(obj)
        obj.each { |name,obj| register_type(obj, name) }
      end

      def register_shapes(obj)
        obj.each { |name,obj| register_shape(obj, name) }
      end

      def register(obj, name = nil, klass = nil)
        #obj = BM_Wrapper.wrap(obj, name, klass) 
        #BM_Registrar.instance.register(obj)
      end

      def register_type(obj, name = nil)
        obj = BM_Type.wrap(obj, name)
        register(obj, name, BM_Type)
      end

      def register_shape(obj, name = nil)
        register(obj, name, BM_Shape)
      end

      def retrieve(obj, name = nil, klass = nil)
        BM_Registrar.instance.retrieve(obj, klass)
      end

      def map(bytes, shape, endian = nil)
        # if you get a BM_Shape just use it to try and build the chunk
        return BM_Chunk.new(bytes, shape, endian) if shape.is_a?(BM_Shape) 

        if registry.registered_name?(shape)
          # if so then you got either the name or the definition, which you can
          # use to get back the shape. Since you are getting it directly from the
          # registry, you get to treat it as valid without having to check it
          # yourself.
          shape = retrieve(shape)
        else
          # if not then you've got to walk through whatever the caller *did* give
          # you and figure out if it's a legit shape. 
        end
      end

      def format_bytes(bytes)
        if Helpers::is_filelike?(bytes)
          err = "Mapping directly from file not supported - bytes must be string-like"
        elsif Helpers::is_stringiolike?(bytes)
          bytes = bytes.string
        end
        bytes = bytes.force_encoding(Encoding::ASCII_8BIT) unless bytes.encoding == Encoding::ASCII_8BIT
      end
    end
  end
end
