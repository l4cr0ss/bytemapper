require 'classes/bm_type'
require 'mixins/registry'

module Bytemapper
  module Classes
    class BM_Shape < Hash
      include Bytemapper::Registry

      def name
        @name
      end

      def name=(value)
        @name = self.class.format_name(value)
      end

      def flatten(flattened = BM_Shape.new, prefix = nil)
        each do |k,v|
          if v.is_a?(Hash)
            k = prefix.nil? ?  k : "#{prefix}_#{k}".to_sym
            v.flatten(flattened, k)
          else
            k = prefix.nil? ?  k : "#{prefix}_#{k}".to_sym
            flattened[k] = v
          end
        end
        flattened
      end

      class << self
        def wrap(obj, name, wrapped = self.new)
          if obj.is_a?(Array)
            wrapped = BM_Type.wrap(obj, name)
          elsif obj.is_a?(Hash)
            obj.each do |k,v|
              wrapped[k] = wrap(v, k)
            end
            wrapped
          elsif obj.is_a?(String) || obj.is_a?(Symbol)
            wrapped = wrap(retrieve(obj), obj)
          else
            raise "Invalid shape definition"
          end
          wrapped
        end

        def register(obj, name)
          Registry.const_set(name, obj)
        end

        def registered?(name)
          return false unless name.is_a?(Symbol)
          Registry.const_defined?(name.upcase.to_sym)
        end

        def retrieve(obj, name = nil)
          name = obj if name.nil?
          Registry.const_get(name.upcase)
        end

        def validate(obj, name)
          [
            format_obj(obj),
            format_name(name)
          ]
        end

        def valid_obj?(obj)
          valid_type?(obj) || valid_shape?(obj) || obj.is_a?(Symbol)
        end

        def valid_shape?(obj)
          obj.is_a?(Hash)
        end

        def valid_type?(obj)
          obj.is_a?(Array)
        end

        def valid_name?(name)
          [
            name.respond_to?(:upcase),
            name.respond_to?(:to_sym)
          ].reduce(:&)
        end

        def format_name(name)
          raise "Bad name" unless valid_name?(name)
          name.upcase.to_sym
        end

        def format_obj(obj)
          return obj if valid_shape?(obj)
          obj
        end
      end
    end
  end
end
