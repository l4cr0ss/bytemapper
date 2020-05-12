require 'test_helper'

# Must fail because it does not override _can_wrap?
class WrapItAllUp 
  extend ::Bytemapper::Mixins::BM_Wrappable
end

# Test the interface to make sure it works right as an interface.
class TestBMWrappable < Minitest::Test
  include TestHelpers

  BM_Type = ::Bytemapper::Classes::BM_Type
  BM_Registry = ::Bytemapper::Classes::BM_Registry

  def test_objects_can_be_wrapped_with_a_string_like_name
    int16_t = BM_Type.wrap([16,'s'], "uint8_t")
    expect = BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
  end

  def test_objects_can_be_wrapped_with_a_symbol_like_name
    int16_t = BM_Type.wrap([16,'s'], :uint8_t)
    expect = BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
  end

  def test_objects_wrapped_with_name_reponds_with_uppercase_symbol
    expect = :UINT8_T
    actual = BM_Type.wrap([16,'s'], :uint8_t).name
    assert_equal(expect, actual)
    actual = BM_Type.wrap([16,'s'], 'uint8_t').name
    assert_equal(expect, actual)
    actual = BM_Type.wrap([16,'s'], :UINT8_T).name
    assert_equal(expect, actual)
  end

  def test_objects_wrapped_with_symbol_and_string_are_equal
    int16_t_sym = BM_Type.wrap([16,'s'], :uint8_t)
    int16_t_str = BM_Type.wrap([16,'s'], "uint8_t")
    assert int16_t_sym == int16_t_str
    assert int16_t_sym.name == int16_t_str.name
  end

  def test_objects_can_be_wrapped_without_a_name
    int16_t = BM_Type.wrap([16,'s'])
    expect = BM_Type
    actual = int16_t.class
    assert_equal(expect, actual)
    assert_nil(int16_t.name)
  end

  def test_objects_wont_be_rewrapped
    int16_t = BM_Type.wrap([16,'s'])
    expect = int16_t.object_id
    actual = BM_Type.wrap(int16_t).object_id
    assert_equal(expect, actual)
  end

  def test_invalid_name_yields_nameless_wrapped_object
    name = { 'lm': '0xAAAA00000' }
    type = [16,'s']
    int16_t = BM_Type.wrap([16,'s'], name)
    assert_nil(int16_t.name)
    assert_equal(type, int16_t)
  end

  def test_mixin_throws_without_under_can_wrap
    assert_raises(NotImplementedError) { WrapItAllUp.wrap([16,'s']) }
  end
end
