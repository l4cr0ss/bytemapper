require 'classes/bm_type'
require 'classes/bm_shape'

module TestHelpers
  BM_Type = ::ByteMapper::Classes::BM_Type
  BM_Shape = ::ByteMapper::Classes::BM_Shape

  def register_test_values
  end

  def register_test_types
    { 
      int8_t: [8,'c'],
      int16_t: [16,'s'],
      int32_t: [32,'l'],
      int64_t: [64,'q'],
      uint8_t: [8,'C'],
      uint16_t: [16,'S'],
      uint32_t: [32,'L'],
      uint64_t: [64,'Q']
    }.each do |name, obj|
      @type_registry.register(BM_Type.wrap(obj, name))
    end
  end

  def register_test_shapes
    {
      outer: { 
        inner: {
          i0: :uint8_t,
          i1: :uint8_t,
          i2: :uint8_t
        },
        o1: :uint8_t
      },
      flattened: {
        inner_i0: :uint8_t,
        inner_i1: :uint8_t,
        inner_i2: :uint8_t,
        o1: :uint8_t
      }
    }
  end
end
