require 'mixins/bm_wrappable'
require 'mixins/helpers'

module ByteMapper
  module Classes
    class BM_Type < Array
      extend ::ByteMapper::Mixins::BM_Wrappable
      extend ::ByteMapper::Mixins::Helpers

      def self.create(obj)
        self.new(obj)
      end

      def self._can_wrap?(obj)
        return false unless obj.respond_to?(:each) and obj.respond_to?(:last)
        [ 
          obj.size == 2,
          obj.first.is_a?(Integer),
          obj.last.respond_to?(:to_sym),
          obj.last.size == 1
        ].reduce(:&)
      end
    end
  end
end
