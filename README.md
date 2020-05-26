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

Now you can access all the fields of the original struct by name!
```ruby
irb(main):016:0> keystate.class
=> Bytemapper::Chunk
irb(main):017:0> 
irb(main):018:0> keystate
=> #<Bytemapper::Chunk:0x0000558105afa6c8 @bytes=#<StringIO:0x0000558105afb398>, @wrapper={
:timestamp=>[32, "L"], :hardwareSwitchState=>[8, "C"], :debouncedSwitchState=>[8, "C"], :cu
rrent=>[8, "C"], :previous=>[8, "C"], :debouncing=>[8, "C"]}, @name=:key_state_t, @timestam
p=4094676062, @hardwareSwitchState=1, @debouncedSwitchState=0, @current=1, @previous=0, @de
bouncing=1>
irb(main):019:0> keystate.hardwareSwitchState
=> 1
irb(main):020:0> keystate.timestamp
=> 4094676062
irb(main):021:0> keystate.debouncing
=> 1
```
