require 'classes/bm_registry'
require 'test_helper'

# Test the BMType to make sure it responds in the way you'd expect it to given
# that it implements the BM_Wrappable interface, and that it can generally
# handle the different scenarios callers might dream up.
class TestBMType < Minitest::Test
  include TestHelpers

  def test_bm_type_wraps_typelike_objects
    # The 'big idea' behind BM_Registry is that the width of a numeric type (short,
    # long, uint16, etc) and the corresponding String#unpack(..) directives for
    # that type get assigned a name. 

    # The type info looks like this:
    my_type = [32, 'L']

    # Name just needs to respond_to? `:to_sym` and `:upcase`:
    my_name = :uint32

    # Register it...
    wrapped = BM_Registry.register(my_type, my_name)

    # The registration you get back has the name
    assert_equal(wrapped.name, my_name)

    # If your implementation is correct then this will succeed:
    assert_equal(wrapped, my_type)
  end

  def test_unwrappable_object_raises
    # If the thing you give to BM_Registry to be wrapped isn't something that it
    # can wrap, it's going to raise an exception. 
    not_type = { a_shape: [16, 'S'] }
    assert_raises(ArgumentError) { BM_Registry.register(not_type, :uint16_t) }
  end

  def test_type_aliases
    # If you register a type under different names...
    BM_Registry.register([8,'C'], :type1_t)
    BM_Registry.register([8,'C'], :type2_t)

    # ..then any of those names can be used to retrieve that type.
    assert_equal([8,'C'], BM_Registry.retrieve(:type1_t).obj)
    assert_equal([8,'C'], BM_Registry.retrieve(:type2_t).obj)

    # ..each will be named accordingly
    assert_equal(:type1_t.upcase, BM_Registry.retrieve(:type1_t).name)
    assert_equal(:type2_t.upcase, BM_Registry.retrieve(:type2_t).name)

    # ..and each will have the others as aliases
    assert_equal(true, BM_Registry.retrieve(:type1_t).aliases.include?(:type2_t.upcase))
    assert_equal(true, BM_Registry.retrieve(:type2_t).aliases.include?(:type1_t.upcase))

  end
end
