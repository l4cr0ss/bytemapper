require 'test_helper'

class TestChunk < Minitest::Test
  include TestHelpers

  def setup
    @registry = Bytemapper.registry
    @registry.reset
    bytes="c9cec506c9cec506c9cec506c9cec506c8cec506"
    @bytes = bytes.scan(/../).map(&:hex).map(&:chr).join
    @shape = {
      s0: :u32,
      s1: :u32,
      s2: :u32,
      s3: :u32,
      s4: :u32,
    }
  end

  def test_chunk
    chunk = Bytemapper.map(@bytes, @shape)
  end
  

end
