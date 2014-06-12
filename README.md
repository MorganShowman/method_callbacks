[![Build Status](https://travis-ci.org/MorganShowman/method_callbacks.svg?branch=master)](https://travis-ci.org/MorganShowman/method_callbacks)

[![Gem Version](https://badge.fury.io/rb/method_callbacks.svg)](http://badge.fury.io/rb/method_callbacks)

# MethodCallbacks

Add after, around, and before callbacks to your methods.

## Installation

Add this line to your application's Gemfile:

    gem 'method_callbacks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install method_callbacks

## Usage

```rb
require "method_callbacks"

class ExampleCallbacks
  include MethodCallbacks

  after_method :action, :farewell, :unload
  after_method :action do
    puts "Executing block callback after action and everything else!"
  end

  before_method :action do
    puts "Executing block callback before action and everything else!"
  end
  before_method :action, :intro
  before_method :action, :greet

  around_method :action, :outer_around, :inner_around

  def outer_around
    puts "Executing pre outer_around!"
    return_value = yield
    puts "Executin post outer_around!"
    return_value
  end

  def inner_around
    puts "Executing pre inner_around!"
    return_value = yield
    puts "Executing post inner_around!"
    return_value
  end

  def action
    puts "Executing action, the method with all teh callbacks!"

    "My return value!"
  end

  def greet
    puts "Executing greet before action but after intro!"
  end

  def intro
    puts "Executing intro before action and greet!"
  end

  def farewell
    puts "Executing farewell after action but before unload!"
  end

  def unload
    puts "Executing unload after action and farewell!"
  end
end

> ExampleCallbacks.new.action
Executing block callback before action and everything else!
Executing intro before action and greet!
Executing greet before action but after intro!
Executing pre outer_around!
Executing pre inner_around!
Executing action, the method with all teh callbacks!
Executing post inner_around!
Executin post outer_around!
Executing farewell after action but before unload!
Executing unload after action and farewell!
Executing block callback after action and everything else!
 => "My return value!"

class TestProxyResult
  include MethodCallbacks

  def result
    "hello!"
  end
  proxy_result(:result) { |original_result| "the original result was: #{original_result}" }

  def result_with_block
    "hello world!"
  end
  proxy_result(:result_with_block) { |original_result, &block| block.call(original_result) }

  def chain_result_proxy
    "original"
  end
  proxy_result(:chain_result_proxy) { |original_result| "original_result: #{original_result}" }
  proxy_result(:chain_result_proxy) { |chained_result| "chained_result: #{chained_result}" }
end

> TestProxyResult.new.result
 => "the original result was: hello!"
> TestProxyResult.new.result_with_block
 => "hello world!"
> TestProxyResult.new.chain_result_proxy
 => "original_result: chained_result: original"
```

## Contributing

1. Fork it ( http://github.com/MorganShowman/method_callbacks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
