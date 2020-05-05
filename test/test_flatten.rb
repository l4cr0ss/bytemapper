require 'minitest/autorun'
require 'stringio'
require 'bytemapper'
require 'types'

class FlattenTest < Minitest::Test
  include ::ByteMapper::Types
  include ::ByteMapper::Shapes

  def setup
    {
      outer: { 
        inner: BM_Shape[{
          i0: UINT8_T,
          i1: UINT8_T,
          i2: UINT8_T
        }],
        o1: UINT8_T
      },
      flattened: {
        inner_i0: UINT8_T,
        inner_i1: UINT8_T,
        inner_i2: UINT8_T,
        o1: UINT8_T
      }
    }.each do |name, shape|
      ByteMapper::Shapes.register_shape(name, shape)
    end
  end

  def test_shape_validation
  end

  def test_flatten
    bytes = String.new "\xc0\xde\xba\xbe", encoding: Encoding::ASCII_8BIT  
    bm1 = ::ByteMapper.map(:outer, bytes)
    bm2 = ::ByteMapper.map(:flattened, bytes)
    byebug
    assert_equal(bm1, bm2)
  end
end
