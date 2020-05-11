module ByteMapper
  module Mixins
    module Helpers
      def self.is_filelike?(candidate)
        candidate.respond_to?(:file) && candidate.respond_to?(:file?) 
      end

      def self.is_stringiolike?(candidate)
        candidate.respond_to?(:read) && candidate.respond_to?(:string) 
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
