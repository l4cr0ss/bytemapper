require 'minitest/autorun'
require 'stringio'
require 'bytemapper'

class ByteMapperTest < Minitest::Test
  def setup
    @bytes64 = {                                        
      '10':  '03003e00010000008006000000000000',
      '20':  '4000000000000000081a000000000000',
      '30':  '0000000040003800090040001d001c00',
      '40':  '06000000040000004000000000000000',
      '50':  '40000000000000004000000000000000',
      '60':  'f801000000000000f801000000000000',
      '70':  '08000000000000000300000004000000',
      '80':  '38020000000000003802000000000000',
      '90':  '38020000000000001c00000000000000'
    }.values.join.scan(/../).map(&:hex).map(&:chr).join

    @bytes_missing = {
      '10':  '03003e00010000008006000000000000',
      '20':  '4000000000000000081a000000000000'
    }.values.join.scan(/../).map(&:hex).map(&:chr).join

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
    @mapper = ByteMapper.new(elf64_ehdr)
  end

  def test_shape
    assert !@mapper.shape.nil?
  end

  def test_hash
    expect = "9e87b3be4ce5b0be9feb9585f81f030042c430dd0a5f9e859860dd9e21c00f98"
    actual = @mapper.hash
    assert_equal expect, actual
  end

  def test_map
    assert @mapper.respond_to? :map
  end

  def test_over_read
    container = @mapper.map(@bytes_missing, 'Ehdr')
    present = [:e_type, :e_machine, :e_version, :e_entry, :e_phoff, :e_shoff]
    empty = [:e_flags, :e_ehsize, :e_phentsize, :e_phnum, :e_shentsize, :e_shnum, :e_shstrndx]
    assert_equal container.present, present
    assert_equal container.missing, empty
    assert_equal 48, container.size
    assert_equal 32, container.used
    assert_equal 16, container.remain
  end

end
