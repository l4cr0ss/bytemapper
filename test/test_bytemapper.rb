require 'test_helper'

class TestBytemapper < Minitest::Test
  include TestHelpers

  def setup
    @bytes = [1,2,3,4,5].map(&:chr).join
    @registry = Bytemapper.registry
    @registry.reset
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
    }

    # Create a chunk from the bytes and shape
    chunk = Bytemapper.map(@bytes, shape)

    # Chunks map bytes to attributes for easy access.
    assert_equal(1, chunk.header.type)
    assert_equal(2, chunk.header.data)
    assert_equal(3, chunk.type)
    assert_equal(4, chunk.data)
    assert_equal(5, chunk.more)
  end

  def test_symbolic_types
    # You can using symbolic names (define your own or use premade ones)
    # instead of literal type definitions.
    Bytemapper.register([8,'C'],:u8)
    shape = {
      header: {
        type: :uint8_t,
        data: :u8,
      },
      type: :u8,
      data: :u8,
      more: :u8
    };
    chunk = Bytemapper.map(@bytes, shape)
    assert_equal(1, chunk.header.type)
    assert_equal(2, chunk.header.data)
    assert_equal(3, chunk.type)
    assert_equal(4, chunk.data)
    assert_equal(5, chunk.more)
  end

  def test_flat
    bytes = "\x5e\xCC\x0F\xF4\x01\x00\x01\x00\x01"
    shape = {
      timestamp: :uint32_t,
      hardwareSwitchState: :bool,
      debouncedSwitchState: :bool,
      current: :bool,
      previous: :bool,
      debouncing: :bool
    }
    Bytemapper.map(bytes, shape, :key_state_t)
  end

  def test_nested
    shape = {
      timestamp: :uint32_t,
      algo: {
        menos: :uint8_t,
        mas: :uint16_t
      }
    }
    bytes = "\x5e\xCC\x0F\xF4\x01\x00\x01\x00\x01"
    nameless = Bytemapper.map(bytes, shape)
    assert_nil(nameless.name)
  end

  def test_reverse_lookup
    shape = {
      d_tag:          :int64_t,    # Dynamic entry type
      d_un:           :uint64_t      # Integer value or address value
    }
    Bytemapper.register(shape, :elf64_dyn)
    lookup = Bytemapper.reverse_lookup(:elf64)
    # [2] pry(#<TestBytemapper>)> pp lookup
    # {[64, "q"]=>:"elf64_dyn.d_tag",
    #  [64, "Q"]=>:"elf64_dyn.d_un",
    #  {:d_tag=>[64, "q"], :d_un=>[64, "Q"]}=>:elf64_dyn}
    assert_equal(lookup.class, Hash)
    assert_equal(lookup.size, 3)
  end
end
