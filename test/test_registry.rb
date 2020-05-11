require 'byebug'
require 'minitest/autorun'
require 'classes/bm_registry'
require 'helpers'

# Test the registry to make sure it does what it's supposed to do. Among other
# things, that means only accepting objects that implement BM_Wrappable, and
# making sure unwrapped objects are rejected with an exception.
class TestBMRegistry < Minitest::Test
  include TestHelpers

  BM_Type = ::ByteMapper::Classes::BM_Type
  BM_Registry = ::ByteMapper::Classes::BM_Registry

  def setup
    @registry = BM_Registry.instance
  end

  def test_registered_objects_can_be_found_by_name
    obj = BM_Type.wrap([8,'C'], :uint8_t)
    @registry.register(obj)
    expect = obj
    actual = @registry.retrieve(:uint8_t)
    assert_equal(expect, actual)
  end

  def test_nameless_object_can_be_registered
    # You can register a definition without a name, if you want
    obj = BM_Type.wrap([128,'B'])
    @registry.register(obj)
    assert_equal(@registry.retrieve(obj), obj)
  end

  def test_registered_objects_can_be_found_without_a_name
    # Retrieve will get the object back if the definition is right, even if the
    # name is wrong or missing.
    obj1 = BM_Type.wrap([16,'S'], :uint16_t)
    @registry.register(obj1)
    obj2 = BM_Type.wrap([16,'S'])
    expect = obj1
    actual = @registry.retrieve(obj2)
    assert_equal(expect, actual)
  end

  def test_name_cannot_be_changed_once_registered
    # Once you give a definition a name, that name will always point to that
    # definition. You can add more names, but you can't take them away or point
    # them to a different definition.
    obj1 = BM_Type.wrap([32,'L'], :uint32_t)
    @registry.register(obj1)
    obj2 = BM_Type.wrap([32,'l'], :uint32_t)
    @registry.register(obj2)
    expect = obj1
    actual = @registry.retrieve(:uint32_t)
    assert_equal(expect, actual)
  end

  def test_object_can_have_multiple_names
    # You can alias an object by registering its definition multiple times.
    obj = BM_Type.wrap([64,'S'], :uint64_t)
    @registry.register(obj)
    obj.name = :us64t
    @registry.register(obj)
    assert_equal(@registry.retrieve(:uint64_t), @registry.retrieve(:us64t))
  end

  def test_nameless_object_will_have_name_after_alias_registration
    # A given definition can only ever be registered once. so if you are going
    # to alias a definition it needs to go update the existing registration for
    # the definition it aliases. By extension, if you registered a definition
    # without a name, then aliasing a name to the definition should give that
    # definition a name. 
    obj = BM_Type.wrap([128,'b'])
    @registry.register(obj)
    assert_nil(@registry.retrieve(obj).name)
    obj.name = :uint128_t
    assert_equal(obj.name, @registry.retrieve(obj).name)
  end

  def test_registered_name?
    # `registered_name?(..)` checks the registry namestore to see if there's a
    # name matching the given argument. It doesn't look at the objstore. The
    # take away is that if this returns true, you are good to assume that there
    # is a definition aliased by the given argument. If it returns false, then
    # all you know is that name isn't an alias for anything.
    obj = BM_Type.wrap([256,'B'], :uint256_t)
    @registry.register(obj)
    assert_equal(true, @registry.registered_name?(:uint256_t))
  end
end
