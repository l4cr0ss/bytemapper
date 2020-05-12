require 'classes/bm_type'
require 'mixins/bm_wrappable'
require 'mixins/helpers'

module Bytemapper
  module Classes
    class BM_Shape < Hash
      extend Mixins::Helpers
      extend Mixins::BM_Wrappable

      def self.create(obj, name = nil, wrapped = self.new)
        if BM_Type.wrap(obj)
          wrapped[name] = BM_Type.wrap(obj)
        else 
          obj.each do |k,v|
            wrapped[k] = BM_Shape.wrap(v, k)
          end
        end
        wrapped
      end

      def terminal?(obj)
      end

      def _flatten(flattened = BM_Shape.new, prefix = nil)
        each do |name, obj|
          # if it's already wrapped then this comes right back
          obj = wrap(obj, name)

          if obj.is_a? BM_Shape
            obj = obj.flatten(flattened, name) 
          elsif obj.is_a? BM_Type
            name = prefix.nil? ? name : "#{prefix}_#{name}".to_sym
          elsif obj.is_a? BM_Chunk
            raise "Can't use '#{obj.class}' to define a #{self.class}"
          else
            raise "Invalid definition while parsing #{self.class}"
          end
          flattened[name] = obj
        end
        flattened
      end

      private

      def self.can_wrap?(obj)
        super
        return false unless  [
          obj.respond_to?(:each_pair),
          obj.respond_to?(:flatten)
        ].reduce(:&)
        return (obj.flatten.size % 2).zero?
      end
    end
  end
end
