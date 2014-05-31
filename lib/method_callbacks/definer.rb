require "forwardable"

module MethodCallbacks
  class Definer
    extend Forwardable

    attr_reader :method

    def_delegators :method, :callbacks, :name

    def initialize(method)
      @method = method
    end

    def define(type, callbacks)
      callbacks.each do |callback|
        callbacks(type) << callback if !callbacks(type).include?(callback)
      end
    end

    def define_with_block(type, &block)
      callbacks(type) << block if !callbacks(type).include?(block)
    end
  end
end
