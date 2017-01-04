# Interface::Dsl

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
  extend FactoryMethods

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

## [HOT] Extend your API at any relevant point

```ruby
# Our BASE API class
class HumanoidAPI
  # Enable DSL
  extend Interface::DSL

  # declare main API
  interface(:base_functions) do |base_api|
    base_api.defpoint(:jump) do |op|
      op.describe "Do jump!"
      op.implementation BaseRobotJump
    end
  end
end

# API Extension class
class JumpExtension
  # Enable DSL
  extend Interface::DSL

  # declare extended API
  interface(:jumping) do |ext|
    ext.defpoint(:on_one_leg) do |op|
      op.describe "Carefully jumps on one leg"
      op.implementation RobotJumpingMaster
    end
  end
end
```

Current legitimate API for HumanoidAPI is

```ruby
HumanoidAPI.base_functions.jump
```

Let's extend it with `JumpExtension`
```ruby
HumanoidAPI.base_functions.extend_api(as: 'weird', with_class: JumpExtension)
```

We've just declaratively extended our API to
```ruby
HumanoidAPI.base_functions.jump
HumanoidAPI.base_functions.weird.jumping.on_one_leg
```

## [WIP] Declare contract for input data by means of dry-validation (available in [input-validation branch](https://github.com/o-kurnenkov/interface-dsl/tree/input-validation))
```ruby
  interface(:midnight_api) do |api|
    api.defpoint(:emergency_push) do |op|
      op.describe "Push the code, fall asleep"
      op.implementation MidnightCodingOperation

      # contract \
      op.contract Dry::Validation.Schema do
        required(:path_to_bed).schema do
          required(:room).filled
        end
      end
      # contract /
    end
  end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/o-kurnenkov/interface-dsl.

