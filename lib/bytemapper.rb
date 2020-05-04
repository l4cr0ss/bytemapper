require 'byebug'
require 'digest'
require 'types'
require 'shapes' 

module ByteMapper

  def self.register_types(types)
    types.constants.each do |s|
      Types.register_type(s, types.const_get(s))
    end
  end

  def self.register_shapes(shapes)
    err = 'register_shapes() expects a hash' 
    raise err unless shapes.class == Hash

    shapes.each do |name, shape|
      name = name.upcase.to_sym
      Shapes.register_shape(name, shape)
    end
  end

  def self.new(shape)
    ByteMapper.new(shape)
  end

  def self.map(name, bytes, edi = nil)
    name = name.upcase.to_sym
    shape = Shapes.const_get(name)
    ByteMapper.new(shape).map(bytes, name, edi)
  end

  class ByteMapper
    attr_reader :shape
    attr_reader :hash

    def initialize(shape)
      @shape = shape
      @hash = Digest::SHA2.hexdigest(shape.inspect)
    end

    # Map bytes of a given endianness to a container of name using attributes
    # and size/flag info stored on its shape definition
    def map(bytes, name, e = nil)

      # If the bytes aren't already file-like then make them that way.
      bytes = bytes.respond_to?(:read) ? bytes : StringIO.new(bytes)

      # Reduce nested shapes until they are flat


      define_shape_as_class(name) unless Object.const_defined?(name)

      obj = klass.nil? ? Object.const_get(name).new : klass.new
      consumed = StringIO.new
      shape.each do |a, sf|
        s, f = sf
        attr = bytes.read(s >> 3)
        !attr.nil? ? consumed << attr : break
        obj[a] = attr.unpack("#{f}#{e}")[0]
      end
      obj.instance_variable_set("@bytes", consumed.string)
      obj
    end

    private

    def define_class(n)
      klass = Struct.new(*shape.keys)
      klass.instance_eval do |i|
        attr_reader :bytes
        define_method(:contents) { members.map(&:to_sym).zip(values).to_h }
        define_method(:shape) { shape }
        define_method(:present) { members.filter { |m| !send(m).nil? } }
        define_method(:missing) { members.filter { |m| send(m).nil? } }
        define_method(:size) { 
          shape.values.map { |v| v[0] >> 3 }.reduce(:+) 
        } 
        define_method(:used) { send(:bytes).size }
        define_method(:full?) { send(:size) == send(:used) }
        define_method(:remain) { send(:size) - send(:used) }
        define_method(:hash) { 
          Digest::SHA2.hexdigest(members.zip(values).join)
        }
      end
      Object.const_set(n, klass)
  end
end
