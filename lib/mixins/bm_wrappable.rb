module ByteMapper
  module Mixins
    module BM_Wrappable

      def self.extended(obj)
        obj.instance_exec { attr_accessor :name }
      end

      def wrap(obj, name = nil)
        return obj if wrapped?(obj)
        return nil unless can_wrap?(obj)
        obj = new(obj) 
        obj.name = name.upcase.to_sym if valid_name?(name)
        obj
      end

      def wrapped?(obj)
        obj.is_a?(self)
      end

      def can_wrap?(obj)
        return true if self == obj.class
        _can_wrap?(obj)
      end

      def valid_name?(name)
        !name.nil? and name.respond_to?(:upcase) and name.respond_to?(:to_sym)
      end

      def _can_wrap?(obj)
        raise NotImplementedError.new("Missing definition for `#{self}#_can_wrap?(..)`")
      end
    end
  end
end
