require 'minitest/autorun'
require 'stringio'
require 'bytemapper'
require 'types'

module TestShapes
  include ::ByteMapper::Types

  InnerShape = {
    member0: UINT8_T,
    member1: UINT8_T,
    member2: UINT8_T
  }

  OuterShape = { 
    member0: InnerShape,
    member1: UINT8_T
  }

  FlattenedShape = {
    member0_member0: UINT8_T,
    member0_member1: UINT8_T,
    member0_member2: UINT8_T,
    member1: UINT8_T
  }
end

class NestedShapeTest < Minitest::Test
  include TestShapes
  def test_nested_shapes
    bytes = "\xc0\xde\xba\xbe"
    ::ByteMapper.register_shapes({outer: OuterShape, 
                                  inner: InnerShape, 
                                  flattened: FlattenedShape})
    byebug
    bm1 = ::ByteMapper.map(:outer, bytes)
    bm2 = ::ByteMapper.map(:flattened, bytes)
    assert_equal(bm1, bm2)
  end
end

shape = {:m0=>{:m0=>{:m0=>[1,"C"]}, :m1=>[1,"C"]}, :m2=>[1,"C"]}
flattened = {}
def recurse(shape, flattened, prefix = nil)
  shape.each do |k,v|
    puts "#{k}, #{v}, #{prefix}"
    new_k = "#{prefix}_#{k}" unless prefix.nil?
    if v.class == Array
      flattened[new_k] = v
    else
      recurse(shape[k], flattened, new_k)
    end
  end
  flattened
end
recurse(shape, flattened)

# recurse(prefix, value)
# base case - member value is an array
#   prefix: value
# case 1 - member value is a hash
#   case 1.1 - member value is not registered
#     register value as a shape using member as key
#   recurse (prefix + "_#{member}", member.value)
