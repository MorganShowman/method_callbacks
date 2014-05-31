require "forwardable"
require "method_callbacks/definer"
require "method_callbacks/executor"
require "method_callbacks/locker"

module MethodCallbacks
  class Method
    extend Forwardable

    attr_reader :name

    def_delegators :definer, :define, :define_with_block
    def_delegators :locker, :lock!, :locked?, :unlock!

    def initialize(name)
      @name = name
    end

    def ==(other)
      self.name == other.name
    end

    def callbacks(type)
      @_callbacks ||= {}
      @_callbacks[type] ||= []
    end

    def execute(type, object)
      block_given? ? executor(type, object).execute(&Proc.new) : executor(type, object).execute
    end

    private

    def executor(type, object)
      Executor.new(self, type, object)
    end

    def definer
      @_definer ||= Definer.new(self)
    end

    def locker
      @_method_lock ||= Locker.new
    end
  end
end
