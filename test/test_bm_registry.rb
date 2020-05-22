require 'test_helper'
require 'classes/bm_registry'

class TestBMRegistry < Minitest::Test
  BM_Registry = Bytemapper::Classes::BM_Registry.instance

  def setup
    BM_Registry.flush
    type = [8,'C']
    name = :uint8_t
    BM_Registry.register(type, name)
    assert_equal(1, BM_Registry.names.size)
    assert_equal(1, BM_Registry.objects.size)
  end

  def test_registration
    BM_Registry.register([16,'S'])
    assert_equal(1, BM_Registry.names.size)
    assert_equal(2, BM_Registry.objects.size)
  end

  def test_registered_name?
    assert_equal(1, BM_Registry.names.size)
    assert_equal(true, BM_Registry.registered_name?(:uint8_t))
  end

  def test_registered_obj?
    BM_Registry.register([16,'S'])
    assert_equal(1, BM_Registry.names.size)
    assert_equal(2, BM_Registry.objects.size)
    assert_equal(false, BM_Registry.registered_name?(:uint16_t))
  end

  def test_retrieval_by_name
    type = [8,'C']
    name = :uint8_t
    BM_Registry.register(type, name)
    result = BM_Registry.retrieve_by_name(:uint8_t)
    assert_equal([8,'C'], result[:obj])
    assert_equal(:uint8_t, result[:name])
    assert_equal(0, result[:aliases].size)
  end

  def test_retrieval_by_obj
    type = [8,'C']
    name = :uint8_t
    BM_Registry.register(type, name)
    result = BM_Registry.retrieve_by_obj(type)
    assert_equal([8,'C'], result[:obj])
    assert_nil(result[:name])
    assert_equal(1, result[:aliases].size)
  end

  def test_aliases
    type = [8,'C']
    [:uint8_t,:bool].each do |name|
      BM_Registry.register(type, name)
    end

    result = BM_Registry.retrieve_by_name(:uint8_t)
    assert_equal([8,'C'], result[:obj])
    assert_equal(:uint8_t, result[:name])
    assert_equal(1, result[:aliases].size)
    assert_equal(true, result[:aliases].include?(:bool))

    result = BM_Registry.retrieve_by_name(:bool)
    assert_equal([8,'C'], result[:obj])
    assert_equal(:bool, result[:name])
    assert_equal(1, result[:aliases].size)
    assert_equal(true, result[:aliases].include?(:uint8_t))
  end

  def test_flush_and_empty
    assert_equal(false, BM_Registry.empty?)
    assert_equal(1, BM_Registry.names.size)
    assert_equal(1, BM_Registry.objects.size)
    BM_Registry.flush
    assert_equal(0, BM_Registry.names.size)
    assert_equal(0, BM_Registry.objects.size)
    assert_equal(true, BM_Registry.empty?)
  end
end
