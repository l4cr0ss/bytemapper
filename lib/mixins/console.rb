module Bytemapper
  module Mixins
    module Console
      def self.included(klass)
        klass.instance_eval do
          define_method(:uint8_t) do 
            [8,'C']
          end

          define_method(:triplynested) do 
            {
              outer: {
                inner: {
                  inner: {
                    inner: { 
                      i0: :uint8_t,
                    },
                    i1: :uint8_t
                  },
                  i2: :uint8_t
                },
                o1: :uint8_t
              }
            }
          end

          define_method(:doublynested) do 
            {
              outer: {
                inner: {
                  inner: {
                    i0: :uint8_t,
                    i1: :uint8_t
                  },
                  i2: :uint8_t
                },
                o1: :uint8_t
              }
            }
          end

          define_method(:nested) do 
            {
              outer: {
                inner: {
                  i0: :uint8_t,
                  i1: :uint8_t,
                  i2: :uint8_t
                },
                o1: :uint8_t
              }
            }
          end

          define_method(:flat) do 
            {
              outer: {
                inner_i0: :uint8_t,
                inner_i1: :uint8_t,
                inner_i2: :uint8_t,
                o1: :uint8_t
              }
            }
          end

          define_method(:awkward) do
            Shape.wrap({
              outer: {
                middle: {
                  inner0: Shape.wrap({
                    i0: Type.wrap([8,'C']),
                    i1: :uint8_t,
                    i2: Type.wrap([16,'S'], :uint16_t)
                  }),
                  inner1: {
                    i0: Type.wrap([8,'C']),
                    i1: :uint8_t,
                    i2: Type.wrap([16,'S'], :uint16_t)
                  }
                }
              }
            })
          end
        end
      end
    end
  end
end
