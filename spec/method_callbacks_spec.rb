require "spec_helper"

describe MethodCallbacks do
  let(:test_callbacks) { TestCallbacks.new }

  it "should execute all the callbacks on action" do
    expect(test_callbacks).to receive(:puts).with("Executing block").ordered
    expect(test_callbacks).to receive(:puts).with("Executing intro").ordered
    expect(test_callbacks).to receive(:puts).with("Executing greet").ordered
    expect(test_callbacks).to receive(:puts).with("Executing pre outer_around").ordered
    expect(test_callbacks).to receive(:puts).with("Executing pre inner_around").ordered
    expect(test_callbacks).to receive(:puts).with("Executing action").ordered
    expect(test_callbacks).to receive(:puts).with("Executing post inner_around").ordered
    expect(test_callbacks).to receive(:puts).with("Executing post outer_around").ordered
    expect(test_callbacks).to receive(:puts).with("Executing farewell").ordered
    expect(test_callbacks).to receive(:puts).with("Executing unload").ordered
    expect(test_callbacks).to receive(:puts).with("Executing block").ordered

    test_callbacks.action
  end
end

class TestCallbacks
  include MethodCallbacks

  after_method :action, :farewell, :unload
  after_method :action do
    puts "Executing block"
  end

  before_method :action do
    puts "Executing block"
  end
  before_method :action, :intro
  before_method :action, :greet

  around_method :action, :outer_around, :inner_around

  def outer_around
    puts "Executing pre outer_around"
    return_value = yield
    puts "Executing post outer_around"
    return_value
  end

  def inner_around
    puts "Executing pre inner_around"
    return_value = yield
    puts "Executing post inner_around"
    return_value
  end

  def action
    puts "Executing action"

    "Return value"
  end

  def greet
    puts "Executing greet"
  end

  def intro
    puts "Executing intro"
  end

  def farewell
    puts "Executing farewell"
  end

  def unload
    puts "Executing unload"
  end
end
