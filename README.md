# Pry-State

Why?
When you are debugging, you care about the state of your program. You want to inspect which value is nil or which array is still empty or something similar. The default pry session doesn't give you all these info. You have to evaluate the variables in the prompt to really see what's going on. It is this problem that this extension of pry is trying to solve.

Pry state is an extension of pry. With pry state you can see the values of the instance and local variables in a pry session.

![SCREENSHOT](https://cloud.githubusercontent.com/assets/1620848/9140567/d57047a4-3d4f-11e5-901e-d508c01c8d52.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pry-state'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pry-state

## Usage

`state-show` is the main command. To learn more (and I suggest you do) use `help state`.

You can turn on the state display as the default by adding this to your `.pryrc`:

    Pry.config.state_hook = true

To turn on truncation of long variables by default, add this to the `.pryrc`:

    Pry.config.state_truncate = true


## Contributing

1. Fork it ( https://github.com/SudhagarS/pry-state/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
