require 'byebug'
require 'minitest/autorun'
require 'mixins/bm_wrappable'
require 'classes/bm_type'

# Must fail because it does not override _can_wrap?
class WrapItAllUp 
  extend ::ByteMapper::Mixins::BM_Wrappable
end

class TestBMWrappable < Minitest::Test

  def test_objects_can_be_wrapped_with_a_string_like_name
    int16_t = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], "uint8_t")
    expect = ::ByteMapper::Classes::BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
  end

  def test_objects_can_be_wrapped_with_a_symbol_like_name
    int16_t = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], :uint8_t)
    expect = ::ByteMapper::Classes::BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
  end

  def test_objects_wrapped_with_name_reponds_with_uppercase_symbol
    expect = :UINT8_T
    actual = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], :uint8_t).name
    assert_equal(expect, actual)
    actual = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], 'uint8_t').name
    assert_equal(expect, actual)
    actual = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], :UINT8_T).name
    assert_equal(expect, actual)
  end

  def test_objects_wrapped_with_symbol_and_string_are_equal
    int16_t_sym = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], :uint8_t)
    int16_t_str = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], "uint8_t")
    assert int16_t_sym == int16_t_str
    assert int16_t_sym.name == int16_t_str.name
  end

  def test_objects_can_be_wrapped_without_a_name
    int16_t = ::ByteMapper::Classes::BM_Type.wrap([16,'s'])
    expect = ::ByteMapper::Classes::BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
    assert_nil(int16_t.name)
  end

  def test_objects_wont_be_rewrapped
    int16_t = ::ByteMapper::Classes::BM_Type.wrap([16,'s'])
    expect = int16_t.object_id
    actual = ::ByteMapper::Classes::BM_Type.wrap(int16_t).object_id
    assert_equal(expect, actual)
  end

  def test_invalid_name_yields_nameless_wrapped_object
    name = { 'lm': '0xAAAA00000' }
    type = [16,'s']
    int16_t = ::ByteMapper::Classes::BM_Type.wrap([16,'s'], name)
    assert_nil(int16_t.name)
    assert_equal(type, int16_t)
  end

  def test_unwrappable_object_yields_nil
    valid_name = 'int16_t'
    invalid_type = [16,['s']]
    invalid = ::ByteMapper::Classes::BM_Type.wrap(invalid_type, valid_name)
    assert_nil(invalid)
  end

  def test_mixin_throws_without_under_can_wrap
    assert_raises(NotImplementedError) { WrapItAllUp.wrap([16,'s']) }
  end
end
