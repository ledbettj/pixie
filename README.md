# Pixie

Pixie is a wrapper for the ws2811 C library for driving ws281x LED strips.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pixie', git: 'https://github.com/ledbettj/pixie.git'
```

And then execute:

    $ bundle install

## Usage

```ruby
require 'pixie'

pixels = Pixie::Pixie.new(Pixie::WS2811_STRIP_RGB, 50)
colors = ['red', 'green', 'blue']
loop do
  pixels[0..49] = colors
  pixels.render
  colors = colors.rotate
  sleep(0.075)
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ledbettj/pixie.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
