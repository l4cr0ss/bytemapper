require 'test_helper'

# Test the Shape to make sure it responds in the way you'd expect it to given
# that it implements the Wrappable interface, and that it can generally
# handle the different scenarios callers might dream up.
class TestShape < Minitest::Test
  include TestHelpers

  def setup
    @registry = Bytemapper.registry
    @registry.reset
  end

  def test_basic_wrap
    # Shape is a key/value store where each key represents a piece of data
    # embedded in a byte string. That data can look like one of two things.
    # Which thing it looks like depends on the value of the key in question,
    # and the value of any given key will always be either: (1) a Shape, or
    # (2) A Registry.
    #
    # So, by traversing the shape recursively and turning any Shapes you
    # encounter into Registrys, you end up with map that you can use to give
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
    # Registry. The `wrap(..)` function takes care of doing that. As it walks
    # through the definition it resolves strings/symbols it encounters.
    #
    # In order for that string or symbol to resolve meaningfully its necessary
    # to first wrap a type using that symbol. So, first, wrap the types you'll
    # need. When you do that, Registry will register it in a namespace that it
    # shares with Shape so that it's available for resolution.
    @registry.put([8,'C'], :uint8_t)

    # ...then you can wrap the definition
    wrapped = Bytemapper.wrap(my_shape, my_name)
    assert_equal(true, wrapped.names.include?(my_name))

    # Symbolic references to Registrys, if any, are resolved:
    expect = my_shape.values.map { |v| @registry.get(v) }
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
    @registry.put([8,'C'], :uint8_t)
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
    obj1 = Bytemapper.wrap(flattened, :flattened)
    obj2 = Bytemapper.wrap(nested, :nested)
    expect = obj1
    actual = obj2.flatten
    assert_equal(expect, actual)
  end

  def test_name
    # Shapes can have names. Names are unique across shapes and types and are
    # what's used to define and resolve symbolic references in literal
    # definitions. The name gets uppercased and symbolized as part of the
    # wrapping process.
    @registry.put([8,'C'], :uint8_t)
    obj = Bytemapper.wrap({'outer': { 'inner': :uint8_t }}, 'test_name')
    assert_equal(true, obj.names.include?(:test_name))
    assert_equal(:outer, obj[:outer].names.first)
  end

  def test_convenience_accessors
    # Shape is a subclass of the native Hash class and it overrides the []
    # operator so that when a new member is added to the shape it becomes
    # accessible via the dot operator.
    inner0 = [8,'C']
    middle1 = [16,'S']
    outer1 = [32,'L']
    @registry.put([8,'C'], :uint8_t)
    @registry.put([16,'S'], :uint16_t)
    @registry.put([32,'L'], :uint32_t)
    obj = Bytemapper.wrap(
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
    @registry.put([8,'C'], :uint8_t)
    Bytemapper.wrap({ member: :uint8_t }, :test_registry_cache)  
    assert_raises { Bytemapper.wrap({ member: :uint8_t, other: :uint_t }, :test_registry_cache) }
  end

  def test_invalid_wrap
    # If the thing you give to Shape to be wrapped isn't something that it
    # can wrap, it's going to raise an exception. 
    not_shape = 16

    assert_raises(ArgumentError) { Bytemapper.wrap(not_shape, :uint16_t) }
  end
end
