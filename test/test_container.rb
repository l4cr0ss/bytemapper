require 'minitest/autorun'
require 'stringio'
require 'mapper'

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
    file.seek(10)
    bytes = file.read()
    @container = mapper.map(bytes, 'Ehdr', '<')
  end

  def test_size
    expect = 48
    actual = @container.size
    assert_equal expect, actual
  end
end
