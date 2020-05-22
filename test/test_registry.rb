require 'test_helper'
require 'classes/registry'
require 'mapper' 

class TestRegistry <  Minitest::Test
  # When type and shape definitions are wrapped the instance is stored in the
  # registry so it can be reused the next time you ask for that definition. 
  include TestHelpers

  def test_registration
  end

  def test_anonymous_registration
    # TODO: Move test from `test/test_bm_shapes` to here
  end

  def test_anonymous_registration_removal
    # When a type or shape is registered anonymously but is later given a name,
    # that type/shape is removed from the anonymous registry.
    anon = BM_Type.wrap([456,'R'])
    assert_nil(anon.name)
    assert_empty(anon.aliases)

    # Type `[456,'R']` has never been named, so it shows up in the anonymous list..
    assert_same(anon, Registry.send(:anonymous?, anon))

    # ..but it won't show up as `registered?` 
    assert_equal(false, Registry.send(:_registered?, anon))
    # ^^^ NOTE: you are asserting the *internal* `_registered?` function
    # returns false, because the public method checks the anonymous registry
    # for you.

    # Re-wrapping it with a name moves it into the registry proper...
    named = BM_Type.wrap([456, 'R'], :OFL)
    assert_equal(anon, Registry.registered?(anon))
    # ...and removes it from the anonymous registry
    assert_equal(false, Registry.send(:anonymous?, anon))
  end

end
