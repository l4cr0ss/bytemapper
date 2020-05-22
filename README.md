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
bytes = "\x35\x31\x30\x39\x30\x31\x38\x35\x34\x33\x00\x01\x01\x01"
```

By rewriting the struct like this:

```ruby
# These definitions are called "shapes"
shape = {
  timestamp: :uint8_t, # these types come for free with the library
  hardwareSwitchState: :bool,
  debouncedSwitchState: :bool,
  current: :bool,
  previous: :bool, # you can define custom types, or alias the prepackaged types
  debouncing: :bool
}
```

You can wrap the bytes into a `BM_Chunk`, like this:

```ruby
keystate = BM_Chunk.wrap(bytes, shape, :key_state_t)
keystate.class
```

And with this object, you can access all the fields of the original struct by name!

```ruby
```
