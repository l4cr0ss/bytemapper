require 'test_helper'

class TestRegistry < Minitest::Test
  include TestHelpers
  
  def setup
    Bytemapper.registry.flush
    @registry = Bytemapper.registry
    type = [8,'C']
    name = :uint8_t
    @registry.put(type, name)
    assert_equal(1, @registry.names.size)
    assert_equal(1, @registry.objects.size)
  end

  def test_registration
    @registry.put([16,'S'])
    assert_equal(1, @registry.names.size)
    assert_equal(2, @registry.objects.size)
  end

  def test_registered_name?
    assert_equal(1, @registry.names.size)
    assert_equal(true, @registry.registered?(:uint8_t))
  end

  def test_registered_obj?
    @registry.put([16,'S'])
    assert_equal(1, @registry.names.size)
    assert_equal(2, @registry.objects.size)
    assert_equal(false, @registry.registered?(:uint16_t))
  end

  def test_retrieval_by_name
    type = [8,'C']
    name = :uint8_t
    @registry.put(type, name)
    result = @registry.get(:uint8_t)
    assert_equal([8,'C'], result)
    assert_equal(:uint8_t, result.names.first)
    assert_equal(1, result.names.size)
  end

  def test_retrieval_by_obj
    type = [8,'C']
    @registry.put(type)
    result = @registry.get(type)
    assert_equal([8,'C'], result)
    assert_equal(1, result.names.size)
  end

  def test_aliases
    type = [8,'C']
    [:uint8_t,:bool].each do |name|
      @registry.put(type, name)
    end

    result = @registry.get(:uint8_t)
    assert_equal([8,'C'], result)
    assert_equal(:uint8_t, result.names.first)
    assert_equal(2, result.names.size)
    assert_equal(true, result.names.include?(:bool))

    result = @registry.get(:bool)
    assert_equal([8,'C'], result)
    assert_equal(true, result.names.include?(:bool))
    assert_equal(2, result.names.size)
    assert_equal(true, result.names.include?(:uint8_t))
  end

  def test_flush_and_empty
    assert_equal(false, @registry.empty?)
    assert_equal(1, @registry.names.size)
    assert_equal(1, @registry.objects.size)
    @registry.flush
    assert_equal(0, @registry.names.size)
    assert_equal(0, @registry.objects.size)
    assert_equal(true, @registry.empty?)
  end
end
