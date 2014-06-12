module MethodCallbacks
  class Executor
    attr_reader :method, :type, :object

    def initialize(method, type, object)
      @method = method
      @type = type
      @object = object
    end

    def execute(&block)
      case type
      when :proxy
        execute_proxy_callbacks(&block)
      when :around
        execute_around_callbacks(&block)
      else
        execute_callbacks
      end
    end

    private

    def callbacks
      method.callbacks(type)
    end

    def execute_around_callbacks
      callbacks.reverse.reduce(Proc.new) { |block, callback_name| Proc.new { object.send(callback_name, &block) } }.call
    end

    def execute_callbacks
      callbacks.each { |callback_name| callback_name.is_a?(Proc) ? object.instance_eval(&callback_name) : object.send(callback_name) }
    end

    def execute_proxy_callbacks(&block_on_call)
      callbacks.reduce(object) { |result, block| block.call(result, &block_on_call) }
    end
  end
end
