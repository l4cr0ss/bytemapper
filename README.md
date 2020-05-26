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
  timestamp: :uint8_t,
  hardwareSwitchState: :bool,
  debouncedSwitchState: :bool,
  current: :bool,
  previous: :bool,
  debouncing: :bool
}
```

You can map the bytes into an object, like this:

```ruby
keystate = Bytemapper.wrap(bytes, shape, :key_state_t)
keystate.class
```

Now you can access all the fields of the original struct by name!
```ruby
```
