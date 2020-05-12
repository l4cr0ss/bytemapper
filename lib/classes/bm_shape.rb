require 'classes/bm_type'
require 'mixins/bm_wrappable'
require 'mixins/helpers'

module ByteMapper
  module Classes
    class BM_Shape < Hash
      extend Mixins::Helpers
      extend Mixins::BM_Wrappable

      # If we're wrapping a new object then that means it hasn't already been
      # wrapped, and if it hasn't already been wrapped then we need to flatten
      # it to make sure that it isn't isomorphic to something that we *have*
      # already wrapped and subsequently registered, because if it is then it
      # means we can just grab that and return it.
      def self.create(obj, name = nil)
        obj = self[obj].flatten
        obj.name = name unless name.nil?
        obj
      end

      def flatten(flattened = BM_Shape.new, prefix = nil)
        each do |name, obj|
          # if it's already wrapped then this comes right back
          obj = wrap(obj, name)
          
          if obj.is_a? BM_Shape
            obj.flatten(flattened, name) 
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

      def self._can_wrap?(obj)
        [ 
          obj.respond_to?(:each_pair),
          (obj.flatten.size % 2).zero?
        ].reduce(:&)
      end
    end
  end
end
