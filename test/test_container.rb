require 'minitest/autorun'
require 'stringio'
require 'bytemapper'

class ContainerTest < Minitest::Test
  def setup
    elf64_ehdr = {
      e_type: [16,'S'],
      e_machine: [16,'S'],
      e_version: [32,'L'],
      e_entry: [64,'Q'],
      e_phoff: [64,'Q'],
      e_shoff: [64,'Q'],
      e_flags: [32,'L'],
      e_ehsize: [16,'S'],
      e_phentsize: [16,'S'],
      e_phnum: [16,'S'],
      e_shentsize: [16,'S'],
      e_shnum: [16,'S'],
      e_shstrndx: [16,'S']		
    }
    mapper = ByteMapper.new(elf64_ehdr)
    file = File.open('test/bin/bytes64.bin','rb')
    file.seek(16)
    bytes = file.read()
    @container = mapper.map(bytes, 'Ehdr', '<')
  end

  def test_size
    assert_equal 48, @container.size
    assert_equal 48, @container.used
    assert_equal 0, @container.remain
  end

  def test_contents
    assert_equal(3, @container.e_type)
    assert_equal(62, @container.e_machine)
    assert_equal(1, @container.e_version)
    assert_equal(0x680, @container.e_entry)
    assert_equal(64, @container.e_phoff)
    assert_equal(6664, @container.e_shoff)
    assert_equal(0, @container.e_flags)
    assert_equal(64, @container.e_ehsize)
    assert_equal(56, @container.e_phentsize)
    assert_equal(9, @container.e_phnum)
    assert_equal(64, @container.e_shentsize)
    assert_equal(29, @container.e_shnum)
    assert_equal(28, @container.e_shstrndx)
  end
end
