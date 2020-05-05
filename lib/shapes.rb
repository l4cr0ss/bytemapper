require 'types'

module ByteMapper
  module Shapes
    include Types
    class BM_Shape < Hash
      attr_accessor :name 

      def flatten(flattened = {}, prefix = nil)
        each do |k,v|
          if v.is_a? self.class
            v.flatten(flattened, k) 
          else
            k = prefix.nil? ? k : "#{prefix}_#{k}".to_sym
            flattened[k] = v
          end
        end
        flattened
      end
    end

    def self.find(name)
      name = name.upcase
      shape = const_get(name) if const_defined?(name)
    end

    def self.register_shape(name, shape)
      shape = BM_Shape[shape] unless shape.is_a? BM_Shape
      shape.name = name
      unless registered?(name)
        shape.each do |k, v|
          if v.class == BM_Shape
            register_shape(k, v)
          end
          shape.define_singleton_method(k) { fetch k }
        end
        const_set(name.upcase, shape) 
      end
    end

    def self.registered?(name)
      const_defined? name.upcase
    end

    def self.valid?(value)
      value.class == BM_Shape || Types.valid?(value)
    end
  end
end
