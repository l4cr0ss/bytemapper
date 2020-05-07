require 'minitest/autorun'
require 'classes/bm_registry'

class TestBMRegistry < Minitest::Test

  def setup
    @hash_registry = ::ByteMapper::Classes::BM_Registry.new(Hash)
    @registry = ::ByteMapper::Classes::BM_Registry.new
    @objs = {
      'fruits': ['mango','peach','grape'],
      colors: ['violet',:yellow],
      '#5': 5
    }.each do |name, obj|
      @registry.register(name, obj)
    end
  end

  def test_registered_objects_can_be_found_by_name
    expect = 5
    actual = @registry.find_by_name('#5')
    assert_equal(expect, actual)
  end

  def test_registered_objects_can_be_found_by_themselves
    expect = 5
    actual = @registry.find_by_hash(5)
    assert_equal(expect, actual)
  end

  def test_name_cannot_be_changed
    obj = { key: 'value' }
    @registry.register('name', obj)
    @registry.register('name', { a_different: 'value' })
    expect = obj
    actual = @registry.find_by_name('name')
    assert_equal(expect, actual)
  end

  def test_object_can_have_multiple_names
    obj = { key: 'value' }
    @registry.register('name', obj)
    @registry.register('eman', obj)
    assert_equal @registry.find_by_name('name'), @registry.find_by_name('eman')
  end

  def test_klass_restricted_registry_prevents_non_klass_obj_registration
    arr = ['LOL', [ 15, 'L' ]]
    expect = "#{@hash_registry.inspect} only accepts objects of type #{@hash_registry.klass}"
    actual = assert_raises(ArgumentError) { @hash_registry.register(*arr) }.message
    assert_equal expect, actual
  end
end
