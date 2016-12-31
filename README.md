# Interface::Dsl

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/interface/dsl`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'interface-dsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install interface-dsl

## Usage

```ruby
# Define an operation class
class MidnightCodingOperation
  # Define :call factory method conveniently
  include Factorymethods

  deffactory :call

  # Or do it manually
  # def self.call(*args)
  #   new(*args).call
  # end

  # Implement some logic
  def call
    puts "Step 1: turn off the light o.o"
    puts "Step 2: git add ."
    puts "Step 3: git commit -m 'asta la vista... (c)'"
    puts "Step 4: git push --force origin master"
    puts "Step 5: fall asleep -.-"
  end
end

# Define a facade API class
class CodeMonkeyAPI
  # Enable DSL
  extend Interface::DSL

  # Define some interface
  interface(:midnight_api) do |api|

    # Define some endpoint
    api.defpoint(:emergency_push) do |op|
      op.describe "Push the code, fall asleep"
      op.implementation MidnightCodingOperation
    end
  end
end

# Activate your operation:
CodeMonkeyAPI.midnight_api.emergency_push.call
#
# => Step 1: turn off the light o.o
# => Step 2: git add .
# => Step 3: git commit -m 'asta la vista... (c)'
# => Step 4: git push --force origin master
# => Step 5: fall asleep -.-
#
# Easy :)
```

## Organize your APIs to honour the Law of Demeter
```ruby
CodeMonkeyAPI                                 # top-level API
MidnightCoderAPI = CodeMonkeyAPI.midnight_api # specific API
MidnightCoderAPI.emergency_push.call          # usage
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/interface-dsl.

