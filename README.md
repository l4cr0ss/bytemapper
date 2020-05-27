# Bytemapper

## What is it?

A way to model and interact with arbitrary byte strings as Ruby objects.

Example:

Consider this struct that models the state of a keyboard switch:

```c
typedef struct {
    uint8_t timestamp;
    volatile bool hardwareSwitchState : 1;
    bool debouncedSwitchState : 1;
    bool current : 1;
    bool previous : 1;
    bool debouncing : 1;
} key_state_t;
```

And this string of bytes representing an instance of the above struct:

```ruby
bytes = "\x5e\xcc\x0f\xf4\x01\x00\x01\x00\x01"
```

By rewriting the struct like this:

```ruby
shape = {
  timestamp: :uint32_t,
  hardwareSwitchState: :bool,
  debouncedSwitchState: :bool,
  current: :bool,
  previous: :bool,
  debouncing: :bool
}
```

You can map the bytes into an object, like this:

```ruby
keystate = Bytemapper.map(bytes, shape, :key_state_t)
```

..and now you can access all the fields of the original struct by name!
```ruby
irb(main):016:0> keystate.class
=> Bytemapper::Chunk
irb(main):017:0> 
irb(main):018:0> keystate
=> #<Bytemapper::Chunk:0x0000558105afa6c8 @bytes=#<StringIO:0x0000558105afb398>, @shape={:timestamp=>[32, "L"], :hardwareSwitchState=>[8, "C"], :debouncedSwitchState=>[8, "C"], :current=>[8, "C"], :previous=>[8, "C"], :debouncing=>[8, "C"]}, @name=:key_state_t, @timestamp=4094676062, @hardwareSwitchState=1, @debouncedSwitchState=0, @current=1, @previous=0, @debouncing=1>
irb(main):019:0> keystate.hardwareSwitchState
=> 1
irb(main):020:0> keystate.timestamp
=> 4094676062
irb(main):021:0> keystate.debouncing
=> 1
```

## Terminology

The json thing that defines the order of the bytes and the name of each member
is called a `shape`. The keys are the names you want to use to refer to the
attributes of the struct you're mapping. The values of those keys are either
(1) another shape or (2) a type. 

A type is an array with two entries. The first item is the width in bits of the
key being described. The second is the unpack directive expected by ruby's
String#unpack method for unpacking bytes like the key being described.

You'll notice that in the above shape, the types were provided as symbols, not
as array literals. By default the library gives you the following types:

```ruby
  [:uint8_t, [8,'C']],
  [:bool, [8,'C']],
  [:uint16_t, [16,'S']],
  [:uint32_t, [32,'L']],
  [:uint64_t, [64,'Q']],
  [:int8_t, [8,'c']],
  [:int16_t, [16,'s']],
  [:int32_t, [32,'l']],
  [:int64_t, [64,'q']]
```

At any point in time you can check the internal registry to see what types have
been defined so far. 

```ruby
irb(main):001:0> Bytemapper.registry.print
+-----------+---------+-------+-----------+
| :uint8_t  |  310565 | Array | [8, "C"]  |
| :bool     |  310565 | Array | [8, "C"]  |
| :uint16_t |  213434 | Array | [16, "S"] |
| :uint32_t |  203010 | Array | [32, "L"] |
| :uint64_t |  561129 | Array | [64, "Q"] |
| :int8_t   |  353623 | Array | [8, "c"]  |
| :int16_t  |  609566 | Array | [16, "s"] |
| :int32_t  |  333146 | Array | [32, "l"] |
| :int64_t  | -246360 | Array | [64, "q"] |
+-----------+---------+-------+-----------+
=> nil
irb(main):002:0> 
```

If you want to add your own types, it's easy - just call the function `wrap()`
and provide the type followed by the name:

```ruby
irb(main):002:0> Bytemapper.wrap([8,"c"],:i8)
=> [8, "c"]
irb(main):003:0> Bytemapper.registry.print
+-----------+---------+-------+-----------+
| :uint8_t  |  310565 | Array | [8, "C"]  |
| :bool     |  310565 | Array | [8, "C"]  |
| :uint16_t |  213434 | Array | [16, "S"] |
| :uint32_t |  203010 | Array | [32, "L"] |
| :uint64_t |  561129 | Array | [64, "Q"] |
| :int8_t   |  353623 | Array | [8, "c"]  |
| :i8       |  353623 | Array | [8, "c"]  |
| :int16_t  |  609566 | Array | [16, "s"] |
| :int32_t  |  333146 | Array | [32, "l"] |
| :int64_t  | -246360 | Array | [64, "q"] |
+-----------+---------+-------+-----------+
=> nil
irb(main):004:0> 
```

If you'd like to set the predefined names to something other than their
defaults, you can do that by calling `reset()` and passing false:
```ruby
# lib/bytemapper/registry.rb
def reset(with_basic_types = true)
  flush
  register_basic_types unless with_basic_types == false
end

# irb
irb(main):004:0> Bytemapper.registry.reset(false)
=> nil
irb(main):005:0> Bytemapper.registry.print

=> nil
irb(main):006:0> 
```

## More examples

If you pass in too few bytes to a map, that's ok:
```ruby
irb(main):010:0> # ..setup the shape as before
irb(main):011:0> bytes = "\x5e\xcc\x0f\xf4\x01\x00\x01"
irb(main):012:0> keystate = Bytemapper.map(bytes, shape)
irb(main):013:0> keystate.current
=> 1
irb(main):014:0> keystate.previous
=> nil
irb(main):015:0> keystate.debouncing
=> nil
```

You can get the memory footprint of the chunk with `size`. The number you get
back is the number of bytes consumed by the mapped bytestring - an underread,
like shown in the previous code snippet, means `size` will be less than the
maximum possible.

```ruby
irb(main):012:0> keystate.size
=> 7
```

On the other hand, you can get the total number of bytes that this chunk can
possibly hold by asking for the size of the underlying shape:
```ruby
irb(main):013:0> keystate.shape.size
=> 9
irb(main):014:0> 
```

You can get the underlying bytes using `bytes`, a reference to the StringIO
object that the chunk was initialized with.
```ruby
irb(main):016:0> keystate.bytes
=> #<StringIO:0x00005568b62fb650>
irb(main):017:0> keystate.bytes.string
=> "^\xCC\x0F\xF4\x01\x00\x01"
```

Here are some additional functions for accessing those same bytes:
```ruby
irb(main):012:0> keystate.string
=> "^\xCC\x0F\xF4\x01\x00\x01"
irb(main):013:0> keystate.ord # == bytes.string.split(//).map(&:ord)
=> [94, 204, 15, 244, 1, 0, 1]
irb(main):014:0> keystate.chr # == bytes.string.split(//).map(&:chr)
=> ["^", "\xCC", "\x0F", "\xF4", "\x01", "\x00", "\x01"]
```


