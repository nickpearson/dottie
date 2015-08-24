# Dottie

Dottie lets you access a Hash or Array (possibly containing other Hashes and Arrays) using a dot-delimited string as the key. The string is parsed into individual keys, and Dottie traverses the data structure to find the target value. If at any point along the way a node is not found, Dottie will return `nil` rather than raising an error.

A great place Dottie is useful is when accessing a data structure parsed from a JSON string, such as when consuming a JSON API. Since the only structural elements JSON can contain are objects and arrays, Dottie can easily access anything parsed from JSON.

Here's a simple example showing a data structure as well as why Dottie is a nice way of accessing the values, especially when certain parts of the data are not guaranteed to be present:

```ruby
car = {
  'color' => 'black',
  'type' => {
    'make' => 'Tesla',
    'model' => 'Model S'
  }
}

# normal Hash access
car['color']            # => "black"
car['type']['make']     # => "Tesla"
car['specs']['mileage'] # => # undefined method `[]' for nil:NilClass

# with Dottie
d = Dottie(car)
d['color']         # => "black"
d['type.make']     # => "Tesla"
d['specs.mileage'] # => nil
```

Here's another example showing a hash containing an array:

```ruby
family = {
  'mom' => 'Alice',
  'dad' => 'Bob',
  'kids' => [
    { 'name' => 'Carol' },
    { 'name' => 'Dan' }
  ]
}

# normal Hash/Array access
family['kids'][0]['name'] # => "Carol"
family['kids'][2]['name'] # => # undefined method `[]' for nil:NilClass
family['pets'][0]['name'] # => # undefined method `[]' for nil:NilClass

# with Dottie
d = Dottie(family)
d['kids[0].name'] # => "Carol"
d['kids[2].name'] # => nil (array only has two elements)
d['pets[0].name'] # => nil ('pets' does not exist)
```

## Installation

Add this line to your application's Gemfile:

    gem 'dottie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dottie

If you want the mixin behavior described below (where you can call `dottie` and `dottie!` on `Hash` and `Array` objects), require `'dottie/ext'` in your Gemfile:

    gem 'dottie', require: 'dottie/ext'

## Usage

First, let's start with some examples of Dottie's behaviors. After that, we'll see how we can access those behaviors.

```ruby
# Since we have to start somewhere, here's one way of getting Dottie's
# behaviors. See the usage options below for different ways of doing
# this and to choose the best option for your app.
data = Dottie({
  'a' => { 'b' => 'c' }
})

# access data with normal keys or with Dottie-style keys
data['a']   # => {"b"=>"c"}
data['a.b'] # => "c"
data.fetch('a.b') # => "c"
data.has_key?('a.b') # => true

# store a value in a nested Hash, then check the Hash
data['a.b'] = 'd'
data['a.b'] # => "d"
data.hash # => {"a"=>{"b"=>"d"}}

# store a value at a new key
data['a.e'] = 'f'
data.hash # => {"a"=>{"b"=>"d", "e"=>"f"}}

# store a value deep in a Hash
# (Dottie fills in the structure when necessary)
h = Dottie({})
h['a.b.c'] = 'd'
h.hash # => {"a"=>{"b"=>{"c"=>"d"}}}

# Dottie can also work with nested Arrays
complex = Dottie({
  'a' => [{ 'b' => 'c' }, { 'd' => 'e' }]
})
complex['a[1].d'] # => "e"

# change the first array element value
complex['a[first].b'] = 'x'
complex.hash # => {"a"=>[{"b"=>"x"}, {"d"=>"e"}]}

# add another array element
complex['a[2]'] = 'y'
complex.hash # => {"a"=>[{"b"=>"x"}, {"d"=>"e"}, "y"]}

# elements can also be prepended and appended to arrays
complex['a[+]'] = 'z' # can also use 'a[<<]' and 'a[append]'
complex.hash # => {"a"=>[{"b"=>"x"}, {"d"=>"e"}, "y", "z"]}

complex['a[-]'] = 'p' # can also use 'a[>>]' and 'a[prepend]'
complex.hash # => {"a"=>["p", {"b"=>"x"}, {"d"=>"e"}, "y", "z"]}

# use delete as you would on a Hash
complex.delete('a[1].b') # => "x"
complex.hash # => {"a"=>["p", {}, {"d"=>"e"}, "y", "z"]}

# delete an element at an array index
complex.delete('a[1]') # => {}
complex.hash # => {"a"=>["p", {"d"=>"e"}, "y", "z"]}
```

### Dottie Usage Options

There are three basic ways of using Dottie:

1. By mixing Dottie's behavior into a `Hash`/`Array` (most versatile)
2. As a wrapper around a Hash or Array (doesn't modify the `Hash`/`Array`)
3. By calling Dottie's module methods directly (more verbose, good for one-off uses)

Here are examples of each of these usage options:

#### 1. Using Dottie as a Mixin

This is the simplest usage. You must `require 'dottie/ext'` in order for the `dottie!` method to be added to `Hash` and `Array`. This can be done in your Gemfile as shown above.

```ruby
require 'dottie/ext' # not necessary if done in the Gemfile

# create a hash and add Dottie's behavior to it
hash = {
  'a' => 'b',
  'c' => {
    'd' => 'e'
  }
}.dottie!

# the hash is still a Hash
hash.class # => Hash

# and it still does normal lookups
hash['a'] # => "b"

# but it can also look up Dottie-style keys now
hash['c.d'] # => "e"
```

The `Hash` and `Array` extensions are a nice but optional way to get convenient access to Dottie's behavior on built-in classes. To add Dottie's behavior to a `Hash` or `Array` without the use of the class extensions, you can extend the object with Dottie's methods. This is what the `dottie!` extension methods do internally.

```ruby
h = {
  'a' => { 'b' => 'c' }
}
h.extend(Dottie::Methods)
h['a.b'] # => "c"
```

#### 2. Using Dottie as a Wrapper

This is the preferred method if you do not wish to modify the `Hash` or `Array` you're working with. In this case, your object will be wrapped in a `Dottie::Freckle`, which will more or less act like the original object. There are a few exceptions to this, such as when checking for equality. (For this, use `.hash` or `.array` to get access to the wrapped object.)

To wrap an object, use `Dottie()` or `Dottie[]` (which are equivalent), or manually create a `Dottie::Freckle` instance. Or, if you have required `'dottie/ext'`, you can call `dottie` (not `dottie!`) on your object.

```ruby
# create a Hash
hash = {
  'a' => { 'b' => 'c' }
}

# then wrap the hash in a Dottie::Freckle with one of these (all equivalent)
d_hash = Dottie(hash)
d_hash = Dottie[Hash]
d_hash = hash.dottie # only available if 'dottie/ext' has been required

# regardless of how the Freckle was created, we can now access its data
d_hash['a'] # => {"b"=>"c"} (a standard Hash lookup)
d_hash['a.b'] # => "c" (a Dottie-style lookup)

# works the same way with Arrays
arr = ['a', { 'b' => 'c' }, 'd']
d_arr = Dottie(arr) # or Dottie[arr] or arr.dottie
d_arr['[1].b'] #=> "c"

# or do it in one line
d_hash = Dottie({ 'a' => 'b' })  # => <Dottie::Freckle {"a"=>"b"}>
d_arr  = Dottie(['a', 'b', 'c']) # => <Dottie::Freckle ["a", "b", "c"]>

# or, use the class extensions (must require 'dottie/ext')
d_hash = { 'a' => 'b' }.dottie  # => <Dottie::Freckle {"a"=>"b"}>
d_arr  = ['a', 'b', 'c'].dottie # => <Dottie::Freckle ["a", "b", "c"]>
```

#### 3. Using Dottie's Methods Directly

This is an easy way to use Dottie's behaviors without modifying your objects and without wrapping them. For this, the syntax is more verbose, but if this suits you, here it is:

```ruby
# create a Hash
hash = {
  'a' => { 'b' => 'c' }
}

# perform a Dottie-style lookup
Dottie.get(hash, 'a.b') # => "c"

# perform a standard lookup to verify there's no Dottie behavior
hash['a.b'] # => nil (there is no literal "a.b" key)

# store a value, Dottie-style
Dottie.set(hash, 'a.b', 'x')
hash # => {"a"=>{"b"=>"x"}}

# store a value, Hash-style
hash['a.b'] = 'z'
hash # => {"a"=>{"b"=>"x"}, "a.b"=>"z"} # stored literally as "a.b"

# let's do another Dottie-style lookup on the modified hash
Dottie.get(hash, 'a.b') # => "x"

# and another standard lookup now that there's a literal "a.b" key
hash['a.b'] # => "z"
```

### Traversing Arrays

Array elements can be targeted with a bracketed index, which is a positive or negative integer or a `first` or `last` named index.

```ruby
me = Dottie({
  'pets' => ['dog', 'cat', 'bird', 'fish']
})
me['pets[first]'] # => "dog"
me['pets[1]']     # => "cat"
me['pets[-2]']    # => "bird"
me['pets[last]']  # => "fish"
```

### Dottie Key Format

Dottie uses periods and brackets to delimit key parts. In general, hash keys are strings separated by periods, and array indexes are integers surrounded by brackets. For example, in the key `a.b[1]`, `a` and `b` are strings (hash keys) and `1` is a bracketed integer (an array index). Here's an example of how this key would be used:

```ruby
d = Dottie({
  'a' => {
    'b' => ['x', 'y', 'z']
  }
})
d['a.b[1]'] # => "y"
```

For readability and convenience, `first` and `last`, when enclosed with brackets (such as `[first]`), are treated as named array indexes and are converted to `0` and `-1`, respectively.

Besides `first` and `last`, any other non-integer string is handled like a normal, dot-delimited string. For example, the key `a[b].c` is equivalent to `a.b.c`.

Brackets can also be used to quote key segments that contain periods. For example, `a[b.c].d` is interpreted internally as `['a', 'b.c', 'd']`. (If you need to see how a key will be interpreted, use `Dottie#key_parts` in an IRB session.)

Dottie is forgiving in its key parsing. Periods are optional around brackets. For example, the key `a[1]b[2]c` is the same as `a.[1].b.[2].c`. Ruby-like syntax is preferred, where a period follows each closing bracket but does not preceed any opening brackets. The preferred key in this case is `a[1].b[2].c`.

### What Dottie Doesn't Do

When mixing Dottie into a `Hash` or `Array`, or when wrapping one in a `Dottie::Freckle` (which passes unrecognized method calls on to the wrapped object), Dottie provides `[]`, `[]=`, `fetch`, and `has_key?` methods, with the latter two assuming you're working with a `Hash`.

By design, Dottie does not provide an implementation for `keys`, `each`, or other built-in `Hash` and `Array` methods where the expected behavior might be ambiguous. Dottie is meant to be an easy way to store and retrieve data in a JSON-like data structure (hashes and/or arrays nested within each other) and is not meant as a replacement for any core classes.

## FAQ

**Q:** Will Dottie make my life easier?  
**A:** Probably.

**Q:** Will Dottie brush my teeth for me?  
**A:** Probably not.

**Q:** Why is the wrapper class named `Freckle`?  
**A:** Why not?

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
