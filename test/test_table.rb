require 'test_helper'

class TestTable < Minitest::Test
  include TestHelpers

  def setup
    @registry = Bytemapper.registry
    @registry.reset
    @bytes = "\x01\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00"\
    "\x00\x00\f\x00\x00\x00\x00\x00\x00\x00\xF0\x05\x00\x00\x00"\
    "\x00\x00\x00\r\x00\x00\x00\x00\x00\x00\x00\xB4\b\x00\x00\x00"\
    "\x00\x00\x00\x19\x00\x00\x00\x00\x00\x00\x00\x98\r \x00\x00"\
    "\x00\x00\x00\e\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x00"\
    "\x00\x00\x00\x1A\x00\x00\x00\x00\x00\x00\x00\xA0\r \x00\x00\x00"\
    "\x00\x00\x1C\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x00\x00"\
    "\x00\x00\xF5\xFE\xFFo\x00\x00\x00\x00\x98\x02\x00\x00\x00\x00"\
    "\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00\xC0\x03\x00\x00\x00"\
    "\x00\x00\x00\x06\x00\x00\x00\x00\x00\x00\x00\xB8\x02\x00\x00"\
    "\x00\x00\x00\x00\n\x00\x00\x00\x00\x00\x00\x00\xAE\x00\x00"\
    "\x00\x00\x00\x00\x00\v\x00\x00\x00\x00\x00\x00\x00\x18\x00"\
    "\x00\x00\x00\x00\x00\x00\x15\x00\x00\x00\x00\x00\x00\x00\x00"\
    "\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00"\
    "\x98\x0F \x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00x"\
    "\x00\x00\x00\x00\x00\x00\x00\x14\x00\x00\x00\x00\x00\x00\x00"\
    "\a\x00\x00\x00\x00\x00\x00\x00\x17\x00\x00\x00\x00\x00\x00"\
    "\x00x\x05\x00\x00\x00\x00\x00\x00\a\x00\x00\x00\x00\x00\x00"\
    "\x00\xB8\x04\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x00\x00"\
    "\x00\x00\xC0\x00\x00\x00\x00\x00\x00\x00\t\x00\x00\x00\x00"\
    "\x00\x00\x00\x18\x00\x00\x00\x00\x00\x00\x00\x1E\x00\x00\x00"\
    "\x00\x00\x00\x00\b\x00\x00\x00\x00\x00\x00\x00\xFB\xFF\xFFo"\
    "\x00\x00\x00\x00\x01\x00\x00\b\x00\x00\x00\x00\xFE\xFF\xFFo"\
    "\x00\x00\x00\x00\x88\x04\x00\x00\x00\x00\x00\x00\xFF\xFF\xFFo"\
    "\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\xF0\xFF\xFFo"\
    "\x00\x00\x00\x00n\x04\x00\x00\x00\x00\x00\x00\xF9\xFF\xFFo\x00"\
    "\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    @bytes.force_encoding(Encoding::ASCII_8BIT)

    shape = {
      d_tag:          :int64_t,
      d_un:           :uint64_t
    }
    @shape = Bytemapper.wrap(shape, :elf64_dyn)
  end

  def test_table_basic_unbounded
    table = Bytemapper.repeat(@shape)
    table = table.populate(@bytes)
    assert_equal(496, table.size)
  end

  def test_table_basic_bounded
    table = Bytemapper.repeat(@shape, 31)
    assert_equal(496, table.size)
    table = table.populate(@bytes)
    assert_equal(496, table.size)
  end

  def test_table_naming
    table = Bytemapper.repeat(@shape)
    table.name = :dynamic
    assert_equal(:dynamic, table.name)
    table.name = :dynamic_LOLKATZ
    assert_equal(:dynamic, table.name)
  end

  def test_table_complex
    shape = { 
        first: :elf64_dyn,
        second: Bytemapper.repeat(:elf64_dyn)
      }
    shape = Bytemapper.register(shape, :pt_dynamic)

    # The table takes up no space at this point, because its size is unknown
    assert_equal(16, shape.size) 
    chunk = Bytemapper.map(@bytes, shape)

    # The standard accessors should be present
    assert_equal('Bytemapper::Table', chunk.second.class.name)

    # The mapped shape should be 496 bytes
    assert_equal(496, shape.size)

    # The entire chunk should be 496 bytes
    assert_equal(496, chunk.size)

    # The populated table should be 480 of those 496 bytes
    assert_equal(480, chunk.second.size)
  end
end
