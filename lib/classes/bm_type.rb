module ByteMapper
  module Classes
    class BM_Type < Array
      extend ::ByteMapper::Mixins::BM_Wrappable

      private 

      def self._can_wrap?(obj)
        [ 
          !obj.nil?,
          obj.respond_to?(:each),
          obj.size == 2,
          obj.first.is_a?(Integer),
          obj.last.respond_to?(:to_sym),
          obj.last.size == 1
        ].reduce(:&)
      end
    end
  end
end
