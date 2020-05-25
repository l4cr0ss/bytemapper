require 'mixins/registry'

module Bytemapper
  module Classes
    class Shape < Hash

      attr_accessor :aliases

      def initialize
        super
        @name = nil
        @aliases = []
      end

      def []=(key, val)
        super
        define_singleton_method(key.to_sym) { fetch(key) } unless respond_to?(key.to_sym)
      end

      def flatten(flattened = self.new, prefix = nil)
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

      def self.wrap(obj, name, wrapped = self.new)
        if obj.is_a?(Array)
          wrapped = Registry.register(obj, name)
        elsif obj.is_a?(Hash)
          obj.each do |k,v|
            wrapped[k] = wrap(v, k)
          end
          wrapped
        elsif obj.is_a?(String) || obj.is_a?(Symbol)
          wrapped = Registry.retrieve(obj)
        else
          raise ArgumentError.new("Invalid shape definition, '#{obj}'")
        end
        wrapped
      end
    end
  end
end
