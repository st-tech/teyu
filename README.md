# Teyu(手湯)

A Ruby class extension for binding initialize method args to instance vars.  
Inspired by [attr_extras](https://github.com/barsoom/attr_extras) gem.

<img src="https://user-images.githubusercontent.com/1746111/62459955-977f9900-b7bb-11e9-98c9-b2e474420941.jpg" width="50%">

Teyu(手湯) is hand bath at Yugawara station.  
I scratched this gem in Yugawara hot spring hotel.

[Yugawara-machi | Yugawara station square maintenance construction was completed!](http://www.town.yugawara.kanagawa.jp.e.td.hp.transer.com/chousei/toshikeikakudoboku/p03787.html)

## Usage

`teyu_init` defines `initialize` method and binds args to same name instance variables.

```ruby
require 'teyu'

class Foo
  extend Teyu
  teyu_init :a, :b

  # Equal to...
  # def initialize(a, b)
  #   @a = a
  #   @b = b
  # end
end

class Bar
  extend Teyu
  teyu_init :c, :d!

  # def initialize(c, d:)
  #   @c = c
  #   @d = d
  # end
end

class Baz
  extend Teyu
  teyu_init :e, f: 'fff'

  # def initialize(e, f: 'fff')
  #   @e = e
  #   @f = f
  # end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'teyu'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teyu

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/st-tech/teyu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Teyu project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/st-tech/teyu/blob/master/CODE_OF_CONDUCT.md).
