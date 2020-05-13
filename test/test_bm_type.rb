require 'test_helper'

# Test the BMType to make sure it responds in the way you'd expect it to given
# that it implements the BM_Wrappable interface, and that it can generally
# handle the different scenarios callers might dream up.
class TestBMType < Minitest::Test
  include TestHelpers

  def test_bm_type_wraps_typelike_objects
    # The 'big idea' behind BM_Type is that the width of a numeric type (short,
    # long, uint16, etc) and the corresponding String#unpack(..) directives for
    # that type get assigned a name. 

    # The type info looks like this:
    my_type = [32, 'L']

    # Name just needs to respond_to? `:to_sym` and `:upcase`:
    my_name = :uint32

    # Wrap it up...
    wrapped = BM_Type.wrap(my_type, my_name)

    # Note that the name *does* get transformed by the wrapper
    assert_equal(wrapped.name, my_name.upcase)

    # If your implementation is correct then this will succeed:
    assert_equal(wrapped, my_type)
  end

  def test_unwrappable_object_raises
    # If the thing you give to BM_Type to be wrapped isn't something that it
    # can wrap, it's going to raise an exception. 
    not_type = { a_shape: [16, 'S'] }
    assert_raises(RuntimeError) { BM_Type.wrap(not_type, :uint16_t) }
  end
end


