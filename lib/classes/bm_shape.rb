require 'mixins/bm_wrappable'
require 'mixins/helpers'

module ByteMapper
  module Classes
    class BM_Shape < Hash
      extend ::ByteMapper::Mixins::Helpers
      extend ::ByteMapper::Mixins::BM_Wrappable

      def self.create(obj)
        self[obj]
      end

      def flatten(flattened = {}, prefix = nil)
        each do |k,v|
          if v.is_a? self.class
            v.flatten(flattened, k) 
          else
            k = prefix.nil? ? k : "#{prefix}_#{k}".to_sym
            flattened[k] = v
          end
        end
        flattened
      end

      private

      def self._can_wrap?(obj)
        [ 
          obj.respond_to?(:each),
          (obj.flatten.size % 2).zero?
        ].reduce(:&)
      end
    end
  end
end
