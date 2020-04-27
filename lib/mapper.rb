require 'byebug'
require 'digest'

module ByteMapper

  def self.configure(types)
    types.constants.each { |c| Types.const_set(c) }
  end

  def self.new(shape)
    ByteMapper.new(shape)
  end

  class ByteMapper
    attr_reader :shape
    attr_reader :hash

    def initialize(shape)
      @shape = shape
      @hash = Digest::SHA2.hexdigest(shape.inspect)
    end

    # Map bytes of a given endianness to a container that will be of name using
    # attributes and size/flag info stored on the shape defining its shape.
    def map(b, n, e = nil)
      shape = @shape
      b = b.respond_to?(:read) ? b : StringIO.new(b)
      c = Object.const_set(n, Struct.new(*shape.keys)).new
      shape.each do |a, sf|
        s, f = sf
        c[a] = b.read(s >> 3).unpack("#{f}#{e}")[0]
      end
      c.define_singleton_method(:shape) { shape }
      c.define_singleton_method(:size) { shape.values.map { |v| v[0] >> 3 }.reduce(:+) }
      c.define_singleton_method(:bytes) { b.string }
      c
    end
  end
end
