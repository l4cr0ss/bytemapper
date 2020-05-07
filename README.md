# ByteMapper

## What is it?

A convenient tool that lets you use user-defined templates - called shapes - to
map arbitrary byte strings to Ruby objects.

For example:

```ruby
shape = {
          b0: :uint8_t,
          b1: :uint8_t,
          b2: :uint8_t,
          b3: :uint8_t
        }

bytes = '\xC0\xDE\xBA\xBE' 



```

Use case: caller has bytes he knows the endianness of that he wants to map to a
struct that he knows the name of.

1. Instantiate mapper with a C struct to map bytes to

2.  Pass bytes, name and endianness to mapper
  StructMapper.map(bytes, endianness, name)

  bytes - a byte string
  endianess - either '<' or '>' or nil. Passed to String#unpack. 
  name - the name of the class that will be returned

3. Mapper uses name to create new container object

4. Mapper uses size info in struct definition + endianness passed by caller to
   map bytes into container

  String#unpack the bytes and map them into the container created in step 3

5. Mapper attaches struct definition to the container

  Attach the definition to the container for future serialization

6. Mapper returns container to caller
