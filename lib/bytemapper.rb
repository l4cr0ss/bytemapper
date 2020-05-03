require 'byebug'
require 'digest'
require 'types'
require 'shapes' 

module ByteMapper

  def self.add_types(types)
    types.constants.each do |s|
      Types.const_set(s, types.const_get(s)) unless Types.const_defined?(s)
    end
  end

  def self.register_shapes(shapes)
    err = 'register_shape() expects a hash' 
    raise err unless shapes.class == Hash

    shapes.each do |key, value|
      key = key.upcase
      Shapes.const_set(key, value) unless Shapes.const_defined? key
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

    # Map bytes of a given endianness to a container that will be of name using
    # attributes and size/flag info stored on the shape defining its shape.
    def map(bytes, n, e = nil)

      # If the bytes aren't already file-like then make them that way.
      bytes = bytes.respond_to?(:read) ? bytes : StringIO.new(bytes)

      # Shape, in C, is the struct.       
      shape = @shape

      # Only define a new container class if the name doesn't already exist.
      unless Object.const_defined?(n)
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

      obj = klass.nil? ? Object.const_get(n).new : klass.new
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
  end
end
