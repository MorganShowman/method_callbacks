module MethodCallbacks
  class Executor
    attr_reader :method, :type, :object

    def initialize(method, type, object)
      @method = method
      @type = type
      @object = object
    end

    def execute
      return execute_callbacks if !block_given?

      callbacks.empty? ? yield : execute_around_callbacks(&Proc.new)
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
  end
end
