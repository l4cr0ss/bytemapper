require 'test_helper'
require 'mapper' 

class TestMapper <  Minitest::Test
  # Mapper is where all the fun happens! 
  # The idea is that this class implements the public API of the library so
  # that it can be included in other projects. That's in contrast to the
  # Bytemapper module, which re-wraps these endpoints for easy
  # command-line/console usage.
  extend Bytemapper::Mapper

  def test_bytes_map_to_chunks_via_shapes
    # This right here is the core functionality of the library: given some
    # bytes and a shape definition, return a "chunk" - an object mapping the
    # bytes to the members defined by the shape.
    info = {
      header: {
        type: :uint8_t,
        data: :uint8_t
      },
      type: :uint8_t,
      data: :uint8_t,
      more: :uint8_t
    };

    bytes = [1,2,1,2,1].map(&:chr).join

    chunk = self.class.map(bytes, info)
  end

end
