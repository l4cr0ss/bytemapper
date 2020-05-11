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
      def self.create(obj)
        byebug
        self[obj].flatten
      end

      def flatten(flattened = {}, prefix = nil)
        each do |k,v|
          # Deal with unwrapped values before proceeding
          unless self.class.wrapped?(v)
            # Check for a definition in the registry
            registry.retrieve(v)
          end

          case v.is_a?
          when BM_Shape
            v.flatten(flattened, k) 
          when BM_Type
            k = prefix.nil? ? k : "#{prefix}_#{k}".to_sym
          when BM_Chunk
            raise "Can't use '#{v.class}' to define a #{self.class}"
          else
            raise "Invalid definition while parsing #{self.class}"
          end
          flattened[k] = v
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
