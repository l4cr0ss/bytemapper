module ByteMapper
  module Classes
    class BM_Shape < Hash
      extend BM_Wrappable

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
        [ obj.respond_to?(:each),
          (obj.size % 2).zero?
        ].reduce(:&)
      end
    end
  end
end
