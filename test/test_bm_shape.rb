require 'test_helper'

# Test the Shape to make sure it responds in the way you'd expect it to given
# that it implements the BM_Wrappable interface, and that it can generally
# handle the different scenarios callers might dream up.
class TestBMShape < Minitest::Test
  include TestHelpers

  def test_that_it_does_in_fact_wrap_what_it_is_supposed_to_wrap
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
    # BM_Type. That's why the BM_Registry exists. It holds the mapping.
    #
    # BM_Shape and BM_Type both have access to the registry as implementors of
    # the BM_Wrappable interface. Look over there for more info.

    # Moving along, first you wrap the types you'll need...
    BM_Type.wrap([8,'C'], :uint8_t)


    # ...then you can wrap the definition
    wrapped = BM_Shape.wrap(my_shape, my_name)

    # Note that the name *does* get transformed by the wrapper
    assert_equal(wrapped.name, my_name.upcase)

    # Transform them back to the original lowercase for the last comparison
    wrapped = wrapped.transform_values { |v| v.name.downcase }

    # If your implementation is correct then this will succeed:
    assert_equal(wrapped, my_shape)
  end

  def test_nested_shape_equals_flattened_shape
    BM_Type.wrap([8,'C'], :uint8_t)
    flattened = {
      outer: {
        inner_i0: :uint8_t,
        inner_i1: :uint8_t,
        inner_i2: :uint8_t
      },
      o1: :uint8_t
    }
    nested = {
      outer: {
        inner: {
          i0: :uint8_t,
          i1: :uint8_t,
          i2: :uint8_t
        },
        o1: :uint8_t
      }
    }
    obj1 = BM_Shape.wrap(flattened)
    obj2 = BM_Shape.wrap(nested)
    byebug
    assert_equal(obj1, obj2)
  end

  def test_unwrappable_object_raises
    # If the thing you give to BM_Shape to be wrapped isn't something that it
    # can wrap, it's going to raise an exception. 
    not_shape = [16, 'S']
    expect = "#{BM_Shape} wrapper incompatible with value '#{not_shape}'"
    invalid = assert_raises(ArgumentError) { BM_Shape.wrap(not_shape, :uint16_t) }
    assert_equal(expect, invalid.message)
  end
end
