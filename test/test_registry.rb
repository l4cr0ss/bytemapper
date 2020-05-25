require 'test_helper'

class TestRegistry < Minitest::Test
  include TestHelpers

  def setup
    Registry.flush
    type = [8,'C']
    name = :uint8_t
    Registry.register(type, name)
    assert_equal(1, Registry.names.size)
    assert_equal(1, Registry.objects.size)
  end

  def test_registration
    Registry.register([16,'S'])
    assert_equal(1, Registry.names.size)
    assert_equal(2, Registry.objects.size)
  end

  def test_registered_name?
    assert_equal(1, Registry.names.size)
    assert_equal(true, Registry.registered?(:uint8_t))
  end

  def test_registered_obj?
    Registry.register([16,'S'])
    assert_equal(1, Registry.names.size)
    assert_equal(2, Registry.objects.size)
    assert_equal(false, Registry.registered?(:uint16_t))
  end

  def test_retrieval_by_name
    type = [8,'C']
    name = :uint8_t
    Registry.register(type, name)
    result = Registry.retrieve(:uint8_t)
    assert_equal([8,'C'], result[:obj])
    assert_equal(:uint8_t, result[:name])
    assert_equal(0, result[:aliases].size)
  end

  def test_retrieval_by_obj
    type = [8,'C']
    name = :uint8_t
    Registry.register(type)
    result = Registry.retrieve(type)
    assert_equal([8,'C'], result[:obj])
    assert_nil(result[:name])
    assert_equal(1, result[:aliases].size)
  end

  def test_aliases
    type = [8,'C']
    [:uint8_t,:bool].each do |name|
      Registry.register(type, name)
    end

    result = Registry.retrieve(:uint8_t)
    assert_equal([8,'C'], result[:obj])
    assert_equal(:uint8_t, result[:name])
    assert_equal(1, result[:aliases].size)
    assert_equal(true, result[:aliases].include?(:bool))

    result = Registry.retrieve(:bool)
    assert_equal([8,'C'], result[:obj])
    assert_equal(:bool, result[:name])
    assert_equal(1, result[:aliases].size)
    assert_equal(true, result[:aliases].include?(:uint8_t))
  end

  def test_flush_and_empty
    assert_equal(false, Registry.empty?)
    assert_equal(1, Registry.names.size)
    assert_equal(1, Registry.objects.size)
    Registry.flush
    assert_equal(0, Registry.names.size)
    assert_equal(0, Registry.objects.size)
    assert_equal(true, Registry.empty?)
  end
end
