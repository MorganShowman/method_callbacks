require "spec_helper"

describe MethodCallbacks do
  let(:test_callbacks) { TestCallbacks.new }
  let(:test_proxy_result) { TestProxyResult.new }

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

    expect(test_callbacks.action).to eq("Return value")
  end

  it "should work when callbacks defined before method definition" do
    expect(test_callbacks).to receive(:puts).with("Executing intro")

    expect(test_callbacks.test_define_before_method).to eq("Executing test_define_before_method")
  end

  it "should work when callbacks defined after method definition" do
    expect(test_callbacks).to receive(:puts).with("Executing unload")

    expect(test_callbacks.test_define_after_method).to eq("Executing test_define_after_method")
  end

  it "should proxy the result" do
    expect(test_proxy_result.result).to eq("the original result was: hello!")
  end

  it "should proxy the result with block" do
    test_string = "the original result was:"
    expect(test_proxy_result.result_with_block do |result|
      "#{test_string} #{result}"
    end).to eq("#{test_string} hello world!")
  end

  it "should chain proxy results" do
    expect(test_proxy_result.chain_result_proxy).to eq("chained_result: original_result: original")
  end
end

class TestCallbacks
  include MethodCallbacks

  def intro
    puts "Executing intro"
  end

  def greet
    puts "Executing greet"
  end

  before_method :action do
    puts "Executing block"
  end
  before_method :action, :intro
  before_method :action, :greet
  def action
    puts "Executing action"

    "Return value"
  end
  after_method :action, :farewell, :unload
  after_method :action do
    puts "Executing block"
  end

  def farewell
    puts "Executing farewell"
  end

  def unload
    puts "Executing unload"
  end

  def outer_around
    puts "Executing pre outer_around"
    return_value = yield
    puts "Executing post outer_around"
    return_value
  end

  around_method :action, :outer_around, :inner_around

  def inner_around
    puts "Executing pre inner_around"
    return_value = yield
    puts "Executing post inner_around"
    return_value
  end

  before_method :test_define_before_method, :intro
  def test_define_before_method
    "Executing test_define_before_method"
  end

  def test_define_after_method
    "Executing test_define_after_method"
  end
  after_method :test_define_after_method, :unload
end

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
