require 'byebug'
require 'digest'
require 'mixins/helpers'
require 'mapper'

module ByteMapper
  Mapper = Classes::Mapper
  Shape = Classes::BM_Shape
  Type = Classes::BM_Type

  def self.included(klass)
    klass.class_eval do

      klass.const_set("Mapper", Mapper)
      klass.const_set("Shape", Shape)
      klass.const_set("Type", Type)

      {
        int8_t: [8,'c'],
        int16_t: [16,'s'],
        int32_t: [32,'l'],
        int64_t: [64,'q'],
        uint8_t: [8,'C'],
        uint16_t: [16,'S'],
        uint32_t: [32,'L'],
        uint64_t: [64,'Q']
      }.each do |name, type|
        Type.wrap(type, name)
      end
    end
  end

end
