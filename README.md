# Jsof

Jsof is library to utilize manipuration of JSON object in Ruby.
It provides wrapper class for Hash and Array to access properties like JavaScript fasion.
If you want, you can define properties explicitly, and add type to them.

(Jsof stand for "JavaScript of".)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsof'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jsof

## Usage

### For normal use

```ruby
require 'jsof'

x = Jsof({a: 1, b: {c: 'a'}})
p x.a  # => 1
p x.b.c  # => 'a'
x.d = 3
x.e = {ee: 4}
p x.to_h  # => {a: 1, b: {c: 'a'}, d: 3, e: {ee: 4}}
```

### define explicit attributes

```ruby
require 'jsof'

class X < Jsof::WrapObject
  define_attr :a    # untyped property
  define_attr :b, type: Integer    # typed property
  define_attr :c, type: Array    # untyped array property
end

x = X.new
x.a = 1
x.b = 'a'    # raise TypeError
x.c = [1, 2]
x.d = 1    # raise NoMethodError
```

Also, you can define nested structure with type.

```ruby
class Y < Jsof::WrapObject
  define_attr :xx, type: X
end

y = Y.new
y.x = {}
y.x.a = 1
y.x.unknown = 1  # raise TypeError

y.x = {unknown: 1}    # Currently, this kind type check is not implemented.
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jljse/jsof.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
