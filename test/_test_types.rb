require 'minitest/autorun'
require 'stringio'
require 'bytemapper'
require 'types'

module ElfTypes
  include ::Bytemapper::Classes::BM_Type
  Elf32_Half = UINT16_T
  Elf64_Half = UINT16_T
  Elf32_Word = UINT32_T
  Elf32_Sword = INT32_T
  Elf64_Word = UINT32_T
  Elf64_Sword = INT32_T
  Elf32_Xword = UINT64_T
  Elf32_Sxword = INT64_T
  Elf64_Xword = UINT64_T
  Elf64_Sxword = INT64_T
  Elf32_Addr = UINT32_T
  Elf64_Addr = UINT64_T
  Elf32_Off = UINT32_T
  Elf64_Off = UINT64_T
  Elf32_Section = UINT16_T
  Elf64_Section = UINT16_T
  Elf32_Versym = Elf32_Half
  Elf64_Versym = Elf64_Half
end

class TypesTest < Minitest::Test
  include ElfTypes

  def setup
    file = File.open('./test/bin/a64.out', 'rb')
    file.seek(16)
    bytes = file.read(48)
    @bytes1 = StringIO.new bytes
    @bytes2 = StringIO.new bytes

    @shape1 = {
      e_type: Elf64_Half,
      e_machine: Elf64_Half,
      e_version: Elf64_Word,
      e_entry: Elf64_Off,
      e_phoff: Elf64_Off,
      e_shoff: Elf64_Off,
      e_flags: Elf64_Word,
      e_ehsize: Elf64_Half,
      e_phentsize: Elf64_Half,
      e_phnum: Elf64_Half,
      e_shentsize: Elf64_Half,
      e_shnum: Elf64_Half,
      e_shstrndx: Elf64_Half		
    }

    @shape2 = {
      e_type: UINT16_T,
      e_machine: UINT16_T,
      e_version: UINT32_T,
      e_entry: UINT64_T,
      e_phoff: UINT64_T,
      e_shoff: UINT64_T,
      e_flags: UINT32_T,
      e_ehsize: UINT16_T,
      e_phentsize: UINT16_T,
      e_phnum: UINT16_T,
      e_shentsize: UINT16_T,
      e_shnum: UINT16_T,
      e_shstrndx: UINT16_T		
    }
  end

  def test_adding_types
    ::Bytemapper.register_types(ElfTypes)
    ::Bytemapper.register_shapes({elf_header1: @shape1})
    ::Bytemapper.register_shapes({elf_header2: @shape2})
    container1 = ::Bytemapper.map(:elf_header1, @bytes1)
    container2 = ::Bytemapper.map(:elf_header2, @bytes2)
    assert_equal(container1.hash, container2.hash)
  end
end
