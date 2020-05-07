require 'lib/bytemapper'

shape = {
          b0: :uint8_t,
          b1: :uint8_t,
          b2: :uint8_t,
          b3: :uint8_t
        }

bytes = '\xC0\xDE\xBA\xBE' 

chunk = ByteMapper.map(shape, bytes)
