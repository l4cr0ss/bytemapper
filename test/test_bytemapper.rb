require 'test_helper'

class TestRegistry < Minitest::Test
  include TestHelpers

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
    keystate = Bytemapper.map(bytes, shape, :key_state_t)
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
  end
end
