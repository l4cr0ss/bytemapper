require 'byebug'
require 'minitest/autorun'
require 'classes/bm_registry'
require 'helpers'

# This test makes sure the registry meets its interface specification.
# The registry only accepts objects implementing the BM_Wrappable interface
# The caller must ensure objects are wrapped prior to calling `.register()`
class TestBMRegistry < Minitest::Test
  include TestHelpers

  BM_Type = ::ByteMapper::Classes::BM_Type
  BM_Registry = ::ByteMapper::Classes::BM_Registry

  def test_registered_objects_can_be_found_by_name
    @registry = BM_Registry.new
    obj = BM_Type.wrap([16,'s'], :uint16_t)
    @registry.register(obj)
    expect = obj
    actual = @registry.retrieve(:uint16_t)
    assert_equal(expect, actual)
  end

  def test_registered_objects_can_be_found_without_a_name
    @registry = BM_Registry.new
    obj = BM_Type.wrap([16,'s'], :uint16_t)
    @registry.register(obj)
    expect = obj
    actual = @registry.retrieve(obj)
    assert_equal(expect, actual)
  end

  def test_name_cannot_be_changed_once_registered
    @registry = BM_Registry.new
    obj1 = BM_Type.wrap([16,'s'], :uint16_t)
    @registry.register(obj1)
    obj2 = BM_Type.wrap([16,'S'], :uint16_t)
    @registry.register(obj2)
    expect = obj1
    actual = @registry.retrieve(:uint16_t)
    assert_equal(expect, actual)
  end

  def test_object_can_have_multiple_names
    @registry = BM_Registry.new
    obj = BM_Type.wrap([16,'s'], :uint16_t)
    @registry.register(obj)
    obj.name = :unsigned_16
    @registry.register(obj)
    assert_equal(@registry.retrieve(:uint16_t), @registry.retrieve(:unsigned_16))
  end

  def test_klass_restricted_registry_prevents_non_klass_obj_registration
    @registry = BM_Registry.new
    arr = ['LOL', [ 15, 'L' ]]
  end
end
