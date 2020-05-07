require 'byebug'
require 'digest'
require 'types'
require 'shapes' 
require 'mapper'

module ByteMapper
  include Helpers
  include Mapper

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

  def self.map(name_or_shape, bytes, edi = nil)
    if is_shapelike?(name_or_shape)
      name = Shapes.register_shape(shape).name
    elsif is_namelike?(name_or_shape)
      name = name_or_shape.to_sym
    else
      err = "First arg to map() must be a shape or the name of a registered shape"
      raise ArgumentError.new(err)
    end

    if is_filelike?(bytes)
      err = "Mapping directly from file not supported - bytes must be string-like"
    elsif is_stringiolike?(bytes)
      bytes = bytes.string
    end
    bytes = bytes.force_encoding(Encoding::ASCII_8BIT) unless bytes.encoding == ENCODING::ASCII_8BIT

    Mapper.map(name, bytes, edi)
  end
end
