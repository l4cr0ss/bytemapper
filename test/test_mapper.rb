require 'test_helper'
require 'mapper' 

class TestMapper <  Minitest::Test
  # The idea is that this class implements the public API of the library so
  # that it can be included in other projects. That's in contrast to the
  # Bytemapper module, which re-registers these endpoints for easy
  # command-line/console usage.
  include Bytemapper::Mapper
  attr_reader :bytes

  def setup
    # Bytes are supplied as a string
    @bytes = [1,2,3,4,5].map(&:chr).join
  end

  def test_mapping_an_anonymous_shape
    # Here is the core functionality of the library: given some bytes and a
    # shape definition, return a "chunk" - an object mapping the bytes to the
    # members defined by the shape.
    shape = {
      header: {
        type: [8,'C'],
        data: [8,'C'],
      },
      type: [8,'C'],
      data: [8,'C'],
      more: [8,'C']
    };

    # Create a chunk from the bytes and shape
    chunk = map(bytes, shape)

    # Chunks map bytes to attributes for easy access.
    assert_equal(1, chunk.header_type)
    assert_equal(2, chunk.header_data)
    assert_equal(3, chunk.type)
    assert_equal(4, chunk.data)
    assert_equal(5, chunk.more)
  end

  def test_symbolic_types
    # You can using symbolic names (define your own or use premade ones)
    # instead of literal type definitions.
    shape = {
      header: {
        type: :uint8_t,
        data: BM_Registry.register([8,'C'],:u8),
      },
      type: :u8,
      data: :u8,
      more: :u8
    };
    byebug
    chunk = map(bytes, shape)
    assert_equal(1, chunk.header_type)
    assert_equal(2, chunk.header_data)
    assert_equal(3, chunk.type)
    assert_equal(4, chunk.data)
    assert_equal(5, chunk.more)
  end
end
