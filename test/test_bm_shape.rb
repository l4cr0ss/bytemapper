require 'test_helper'

# Test the Shape to make sure it responds in the way you'd expect it to given
# that it implements the BM_Wrappable interface, and that it can generally
# handle the different scenarios callers might dream up.
class TestBMShape < Minitest::Test
  include TestHelpers

  def test_basic_wrap
    # BM_Shape is a key/value store where each key represents a piece of data
    # embedded in a byte string. That data can look like one of two things.
    # Which thing it looks like depends on the value of the key in question,
    # and the value of any given key will always be either: (1) a BM_Shape, or
    # (2) A BM_Type.
    #
    # So, by traversing the shape recursively and turning any BM_Shapes you
    # encounter into BM_Types, you end up with map that you can use to give
    # meaning to a stream of arbitrary bytes.

    # Example:
    #
    # typedef struct {
    #   uint8_t timestamp;
    #   volatile bool hardwareSwitchState : 1;
    #   bool debouncedSwitchState : 1;
    #   bool current : 1;
    #   bool previous : 1;
    #   bool debouncing : 1;
    # } key_state_t;

    # name it..
    my_name = :key_state_t

    # define it..
    my_shape = { 
      timestamp: :uint8_t,
      hardwareSwitchState: :uint8_t,
      debouncedSwitchState: :uint8_t,
      current: :uint8_t,
      previous: :uint8_t,
      debouncing: :uint8_t
    }

    # Ok.. notice that those definitions are nice and friendly when you type
    # them but they don't mean much without some sort of mapping back to the
    # BM_Type. The `wrap(..)` function takes care of doing that. As it walks
    # through the definition it resolves strings/symbols it encounters.
    #
    # In order for that string or symbol to resolve meaningfully its necessary
    # to first wrap a type using that symbol. So, first, wrap the types you'll
    # need. When you do that, BM_Type will register it in a namespace that it
    # shares with BM_Shape so that it's available for resolution.
    BM_Type.wrap([8,'C'], :uint8_t)

    # ...then you can wrap the definition
    wrapped = BM_Shape.wrap(my_shape, my_name)

    # The name gets upcased:
    assert_equal(my_name.upcase, wrapped.name)

    # Symbolic references to BM_Types, if any, are resolved:
    expect = my_shape.values.map { |v| BM_Type.retrieve(v.upcase) }
    actual = wrapped.values
    assert_equal(expect, actual)
  end

  def test_nested_shape_equals_flattened_shape
    # The `flatten()` function offers a way of collapsing nested shapes into a
    # 1-dim array so that the definitions can be walked when it's time to apply
    # them to a byte string.
    #
    # You'll see that it concatenates the names of the nested shapes it
    # flattens, adding them together each time it recurses to build a prefix
    # for each leaf node it ultimately encounters.
    #
    # You'll also notice that it proceeds in a depth first manner, in order
    # that the sequence of the types is preserved in the final list. This is
    # important when the entire point is to have these types describing
    # specific offsets into a byte string.
    BM_Type.wrap([8,'C'], :uint8_t)
    flattened = {
      outer0_middle0_inner0: :uint8_t,
      outer0_middle0_inner1: :uint8_t,
      outer0_middle0_inner2: :uint8_t,
      outer0_middle1: :uint8_t,
      outer1: :uint8_t
    }
    nested = {
      outer0: {
        middle0: {
          inner0: :uint8_t,
          inner1: :uint8_t,
          inner2: :uint8_t
        },
        middle1: :uint8_t
      },
      outer1: :uint8_t
    }
    obj1 = BM_Shape.wrap(flattened, :flattened)
    obj2 = BM_Shape.wrap(nested, :nested)
    expect = obj1
    actual = obj2.flatten
    assert_equal(expect, actual)
  end

  def test_name
    # Shapes can have names. Names are unique across shapes and types and are
    # what's used to define and resolve symbolic references in literal
    # definitions. The name gets uppercased and symbolized as part of the
    # wrapping process.
    BM_Type.wrap([8,'C'], :uint8_t)
    obj = BM_Shape.wrap({'outer': { 'inner': :uint8_t }}, 'test_name')
    assert_equal(:TEST_NAME, obj.name)
    assert_equal(:OUTER, obj[:outer].name)
    assert_equal(:INNER, obj[:outer][:inner].name)
  end

  def test_anonymous_wrap
    # It's possible to wrap a shape without a name and end up with an anonymous
    # shape (one without a name). However! If you've previously wrapped the
    # same definition _with_ a name then when `wrap()` returns you the wrapped
    # shape it will have come from the registry and will have a list of all the
    # names referencing that definition accessible via the `aliases` attribute.
    #
    # Example:

    # Wrap a type definition to use in the shape definition.
    BM_Type.wrap([8,'C'], :uint8_t)

    # As discussed, first wrap the shape with a name so it gets registered.
    obj = BM_Shape.wrap({'outer': { 'inner': :uint8_t }}, :test_anon_wrap)

    # Now wrap the shape again, but without passing a name, and assert that
    # the object you get back has name, that it's the same name. and that the
    # objects are equal.
    anon = BM_Shape.wrap({'outer': { 'inner': :uint8_t }})
    assert_equal(true, anon.name.nil?)
    assert_equal(true, anon.aliases.include?(obj.name))
    assert_equal(obj, anon)
  end

  def test_convenience_accessors
    # Shape is a subclass of the native Hash class and it overrides the []
    # operator so that when a new member is added to the shape it becomes
    # accessible via the dot operator.
    inner0 = BM_Type.wrap([8,'C'], :uint8_t)
    middle1 = BM_Type.wrap([16,'S'], :uint16_t)
    outer1 = BM_Type.wrap([32,'L'], :uint32_t)
    obj = BM_Shape.wrap(
      {
        outer0: { 
          middle0: {
            inner0: :uint8_t
          },
          middle1: :uint16_t,
        },
        outer1: :uint32_t
      }, :test_convenience_accessors)
    assert_equal(obj[:outer0], obj.outer0 )
    assert_equal(obj[:outer0][:middle0], obj.outer0.middle0)
    assert_equal(obj[:outer0][:middle0][:inner0], obj.outer0.middle0.inner0)
    assert_equal(inner0, obj.outer0.middle0.inner0)
    assert_equal(obj[:outer0][:middle1], obj.outer0.middle1)
    assert_equal(middle1, obj.outer0.middle1)
    assert_equal(obj[:outer1], obj.outer1)
    assert_equal(outer1, obj.outer1)
  end

  def test_registry_cache
    # Shapes, like types, get registered by their name as part of the wrapping
    # process, making them available for reuse. This test makes sure that when
    # you are wrapping a shape this cache gets checked and used when possible. It
    # serves two purposes: (1) it greatly reduces the possibility (anything's
    # possible amirite LOL) of having two shapes with the same name but different
    # contents, and (2) it gives a very (very) small performance boost. 
    BM_Type.wrap([8,'C'], :uint8_t)

    # The test works by taking advantage of the fact that the registry will not
    # overwrite an existing name <-> object registration unless explicitly
    # requested. 
    obj1 = BM_Shape.wrap({ member: :uint8_t }, :test_registry_cache)  
    refute_nil(BM_Shape.registered?(:test_registry_cache))

    # So, by wrapping a new, different, object under a known registered name you can
    # assert that the actual object returned will be the one originally
    # registered to the name, and in doing so test that the registry is
    # actually being used.
    obj2 = BM_Shape.wrap({ member: :uint8_t, other: :uint_t }, :test_registry_cache)
    assert_equal(obj1, obj2)
    assert_equal(obj2, BM_Shape.retrieve(:test_registry_cache))
  end

  def test_invalid_wrap
    # If the thing you give to BM_Shape to be wrapped isn't something that it
    # can wrap, it's going to raise an exception. 
    not_shape = [16, 'S']

    assert_raises(ArgumentError) { BM_Shape.wrap(not_shape, :uint16_t) }
  end
end
