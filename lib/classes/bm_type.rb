require 'mixins/registry'

module Bytemapper
  module Classes
    class BM_Type < Array
      include Bytemapper::Registry

      def name
        @name
      end

      def name=(value)
        @name = self.class.format_name(value)
      end

      class << self
        def wrap(obj, name)
          obj, name = validate(obj, name)
          return retrieve(name) if registered?(name)
          obj = new(obj)
          obj.name = name
          register(obj, name) unless registered?(name)
          obj
        end

        def register(obj, name)
          Registry.const_set(name, obj)
        end

        def registered?(name)
          Registry.const_defined?(name)
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
      end
    end
  end
end
