require 'classes/bm_type'
require 'mixins/registry'

module Bytemapper
  module Classes
    class BM_Shape < Hash
      include Bytemapper::Registry

      attr_accessor :aliases

      def initialize
        super
        @name = nil
        @aliases = nil
      end

      def name
        @name
      end

      def name=(value)
        @name = self.class.format_name(value)
      end

      def []=(key, val)
        super
        define_singleton_method(key.to_sym) { fetch(key) } unless respond_to?(key.to_sym)
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
        def register(obj, name)
          Registry.register(obj)
        end

        def registered?(key, name = nil)
          obj = Registry.registered?(key)
          obj || Registry.registered?(name)
        end

        def retrieve(obj, name = nil)
          Registry.retrieve(obj, name)
        end

        def format_name(name)
          raise "Bad name: '#{name}'" unless valid_name?(name)
          name.upcase.to_sym
        end

        def format_obj(obj)
          return obj if valid_shape?(obj)
          obj
        end

        def wrap(obj, name = nil, force = false)
          raise ArgumentError.new("Invalid shape definition, '#{obj}'") unless obj.is_a?(Hash)
          # Check if it exists already to prevent re-wrapping
          return retrieve(obj, name) if registered?(obj, name)
          wrapped = _wrap(obj, name)
          self.register(wrapped, wrapped.name)
        end

        private

        def _wrap(obj, name, wrapped = self.new)
          if obj.is_a?(Array)
            wrapped = BM_Type.wrap(obj, name)
          elsif obj.is_a?(Hash)
            obj.each do |k,v|
              wrapped[k] = _wrap(v, k)
            end
            wrapped
          elsif obj.is_a?(String) || obj.is_a?(Symbol)
            wrapped = _wrap(retrieve(obj), obj)
          else
            raise ArgumentError.new("Invalid shape definition, '#{obj}'")
          end
          wrapped.name = name unless name.nil?
          wrapped
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
      end
    end
  end
end
