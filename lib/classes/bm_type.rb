require 'mixins/registry'

module Bytemapper
  module Classes
    class BM_Type < Array
      include Bytemapper::Registry

      attr_reader :aliases

      def name
        @name
      end

      def name=(value)
        @name = self.class.format_name(value)
      end

      def initialize(*)
        super
        @name = nil
        @aliases = []
      end

      class << self
        def wrap(obj, name = nil, force = false)
          raise ArgumentError.new("Invalid type definition, '#{obj}'") unless obj.is_a?(Array) || obj.is_a?(Symbol) || obj.is_a?(String)
          # Check if it exists already to prevent re-wrapping
          wrapped = registered?(obj, name)
          return wrapped if wrapped
          wrapped = new(obj)
          wrapped.name = name unless name.nil?
          self.register(wrapped)
        end

        def register(obj)
          Registry.register(obj)
        end

        def registered?(key, name = nil)
          obj = Registry.registered?(key)
          register_alias(obj, name) if obj && obj.name != name
          obj || Registry.registered?(name)
        end

        def retrieve(name)
          Registry.const_get(name)
        end

        def validate(obj, name)
          [
            format_obj(obj),
            format_name(name)
          ]
        end

        def valid_obj?(obj)
          return false unless obj.is_a? Array
          [ 
            obj.size == 2,
            obj.first.is_a?(Integer),
            obj.last.respond_to?(:to_sym),
            obj.last.size == 1
          ].reduce(:&)
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
          raise "Bad obj" unless valid_obj?(obj)
          obj
        end

        def register_alias(obj, name)
          obj.name = name
          Registry.register(obj)
        end
      end
    end
  end
end
