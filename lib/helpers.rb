module ByteMapper
  module Helpers
    def self.is_filelike?(candidate)
      is_iolike?(candidate) && candidate.respond_to?(:file?) 
    end

    def self.is_stringiolike?(candidate)
      candidate.respond_to?(:read) && candidate.respond_to?(:string) 
    end

    def self.is_namelike?(candidate)
      candidate.respond_to?(:to_sym)
    end

    def self.is_shapelike?(candidate)
    end

    def self.is_typelike?(candidate)
    end

    def self.is_name_or_type?(candidate)
    end
  end
end
