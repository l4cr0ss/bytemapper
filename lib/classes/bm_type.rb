require 'classes/bm_registry'

module Bytemapper
  module Classes
    class BM_Type < Array

      Registry = Bytemapper::Classes::BM_Registry.instance

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
        # Wraps the given object as a BM_Type, optionally naming (or aliasing) it
        # as appropriate.
        # 
        # @param name [Array] The object to be wrapped.
        # @return [BM_Type] The wrapped object.
        def wrap(obj, name = nil)
          registration = Registry.registered?(obj, name)

          if registration
            # the object is registered..
            if registration[:name].nil?
              # ..but not under this name
            else
            end
          else
            # if name is *not* nil then the value in obj may be one of:
            # 1. a type literal (i.e. [8, 'C'])
            # 2. a BM_Type object (i.e. already wrapped)
            # and the value in name must respond like a string or symbol

          end
          wrapped = registered?(obj, name)
          return wrapped if wrapped
          wrapped = new(obj)
          wrapped.name = name unless name.nil?
          self.register(wrapped)
        end

        def type_literal?(obj)
          obj.is_a?(Array) && !obj.is_a?(BM_Type)
        end

        def name_literal?(name)
          obj.is_a?(Symbol) || obj.is_a?(String)
        end

        def register(obj)
        end

        def registered?(key, name = nil)
        end

        def retrieve(name)
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
