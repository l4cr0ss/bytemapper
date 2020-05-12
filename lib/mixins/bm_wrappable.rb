require 'classes/bm_registry'

module ByteMapper
  module Mixins
    module BM_Wrappable

      @@registry = Classes::BM_Registry.new

      def self.extended(obj)
        obj.instance_exec do 
          define_method(:name) do
            @name ||= nil
          end

          define_method(:name=) do |value|
            raise "Name must respond to :upcase and :to_sym" unless self.class.valid_name?(value)
            @name = value.upcase.to_sym
          end
          
          define_method(:wrap) do |obj, name|
            self.class.wrap(obj, name)
          end
        end
      end

      def wrap(obj, name = nil)
        # if you got handed a wrapped object just hand it back
        return obj if wrapped?(obj)

        # check the registry for it (and maybe register a new alias)
        wrapped = @@registry.retrieve(obj, name)
        return wrapped unless wrapped.nil?

        # if you have to wrap it well make sure it can be done first
        raise ArgumentError.new("#{self} wrapper incompatible with value '#{obj}'") unless can_wrap?(obj)

        # better nameless than something weird
        name = name.upcase.to_sym if valid_name?(name)

        # build it and put it in the registry for future use
        obj = create(obj, name) 
        @@registry.register(obj)
      end

      def wrapped?(obj)
        obj.class.singleton_class.included_modules.include?(BM_Wrappable)
      end

      def can_wrap?(obj)
        return true if self == obj.class
        _can_wrap?(obj)
      end

      def _can_wrap?(obj)
        raise NotImplementedError.new("Missing definition for `#{self}#_can_wrap?(..)`")
      end

      def valid_name?(name)
        !name.nil? and name.respond_to?(:upcase) and name.respond_to?(:to_sym)
      end
    end
  end
end
