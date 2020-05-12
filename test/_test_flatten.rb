require 'minitest/autorun'
require 'classes/bm_shape'
require 'bytemapper'
require 'stringio'

class FlattenTest < Minitest::Test
  include Bytemapper

  BM_Type = ::Bytemapper::Classes::BM_Type
  BM_Shape = ::Bytemapper::Classes::BM_Shape
  BM_Registry = ::Bytemapper::Classes::BM_Registry

  def setup
    {
      mixed: {
        inner0: [8,'C'],
        inner1: :uint8_t
      },
      resolved: {
        inner0: [8,'C'],
        inner1: [8,'C']
      },
      symbolic: {
        inner0: :uint8_t,
        inner1: :uint8_t
      },
      outer: { 
        inner: {
          i0: :uint8_t,
          i1: :uint8_t,
          i2: :uint8_t
        },
        o1: :uint8_t
      },
      flattened: {
        inner_i0: :uint8_t,
        inner_i1: :uint8_t,
        inner_i2: :uint8_t,
        o1: :uint8_t
      },
      wrong: {
        uint8_t: {
          inner_i0: :uint8_t,
          inner_i1: :uint8_t,
          inner_i2: :uint8_t,
        }
      }
    }.each do |name, shape|
      byebug
      Bytemapper.register_shape(shape, name)
    end
  end

  def test_shape_validation
  end

  def test_flatten
    bytes = String.new "\xc0\xde\xba\xbe", encoding: Encoding::ASCII_8BIT  
    bm1 = Bytemapper.map(bytes, :outer)
    bm2 = Bytemapper.map(bytes, :flattened)
    assert_equal(bm1, bm2)
  end
end
