module ByteMapper
  module Mixins
    module Helpers
      def self.is_filelike?(obj)
        obj.respond_to?(:file) && obj.respond_to?(:file?) 
      end

      def self.is_stringiolike?(obj)
        obj.respond_to?(:read) && obj.respond_to?(:string) 
      end

      def self.is_stringlike?(obj)
        [
          obj.respond_to?(:to_sym),
          obj.respond_to?(:upcase)
        ].reduce(:&)
      end
    end
  end
end
