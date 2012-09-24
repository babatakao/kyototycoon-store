# Kyototycoon::Store

__`kyototycoon-store`__ provides stores (*Cache*) for __ActiveSupport__.
It supports expires_in and delete_matched.

## Installation

Add this line to your application's Gemfile:

    gem 'kyototycoon-store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kyototycoon-store

## Usage

    # Gemfile
        gem 'kyototycoon-store'
    # config/environments/production.rb
        config.cache_store = :kyototycoon_store

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
