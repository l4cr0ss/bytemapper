require 'mixins/bm_wrappable'
require 'mixins/helpers'

module Bytemapper
  module Classes
    class BM_Type < Array
      extend ::Bytemapper::Mixins::BM_Wrappable
      extend ::Bytemapper::Mixins::Helpers

      def self.create(obj, name = nil)
        obj = self.new(obj)
        obj.name = name if self.valid_name?(name)
        obj
      end

      def self.can_wrap?(obj)
        super
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
