module Bytemapper
  using Refinements

  class Table < Array
    include Flattenable
    include Nameable
    attr_reader :bytes, :shape

    def initialize(shape, rows = nil)
      @bytes = nil
      @shape = Bytemapper.get(shape)
    end

    def populate(bytes)
      @bytes = StringIO.from(bytes)

      table = Table.new(shape)
      table.clear

      (bytes.size / shape.size).times do
        table << Chunk.new(@bytes.read(shape.size), shape, shape.name)
      end

      table
    end

    def size
      empty? ? 0 : map(&:size).reduce(:+)
    end

  end
end
