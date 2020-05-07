require 'minitest/autorun'
require 'mixins/bm_wrappable'
require 'classes/bm_type'

class TestBMWrappable < Minitest::Test

  def setup
  end

  def test_objects_can_be_wrapped
    int16_t = ::ByteMapper::Classes::BM_Type.wrap([16,['s']])
    expect = ::ByteMapper::Classes::BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
  end

  def test_objects_wont_be_rewrapped
  end

  def test_wrappable_name_error
  end

  def test_wrappable_type_error
  end

  def test_can_wrap_implementation_exists
  end
end
