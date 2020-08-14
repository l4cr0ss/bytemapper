module Bytemapper
  module NilTimes
    refine NilClass do
      def times
        0
      end
    end
  end

  class Table < Array
    include Flattenable
    include Nameable
    attr_reader :shape, :rows, :bytes
    using NilTimes

    def initialize(shape, rows = nil)
      @shape = Bytemapper.get(shape)
      rows.times { self << @shape  }
    end

    def populate(bytes)
      bytes = bytes.nil? ? '' : bytes
      @bytes = bytes.is_a?(StringIO) ? bytes : StringIO.new(bytes)
      @bytes.string.force_encoding(Encoding::ASCII_8BIT)
      if unbounded?
        (bytes.size / shape.size).times { self << @shape } 
      end

      table = Table.new(shape) 
      table.clear
      (bytes.size / shape.size).times { table << Chunk.new(@bytes.read(shape.size), shape, shape.name) }
      table
    end

    def unbounded?
      empty?
    end

    def size
      empty? ? 0 : map(&:size).reduce(:+)
    end
  end
end

