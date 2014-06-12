require "method_callbacks/finder"
require "method_callbacks/version"

module MethodCallbacks
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def after_method(method_name, *callback_names)
      define(method_name, :after, callback_names)
      define_with_block(method_name, :after, &Proc.new) if block_given?
    end

    def around_method(method_name, *callback_names)
      define(method_name, :around, callback_names)
    end

    def proxy_result(method_name, &block)
      define_with_block(method_name, :proxy, &block)
    end

    def before_method(method_name, *callback_names)
      define(method_name, :before, callback_names)
      define_with_block(method_name, :before, &Proc.new) if block_given?
    end

    private

    def define(method_name, type, callback_names)
      find_or_new(method_name).define(type, callback_names)
    end

    def define_with_block(method_name, type)
      find_or_new(method_name).define_with_block(type, &Proc.new)
    end

    def find(method_name)
      finder(method_name).find
    end

    def finder(method_name)
      @_finder ||= {}
      @_finder[method_name] ||= MethodCallbacks::Finder.new(method_name)
    end

    def find_or_new(method_name)
      method = finder(method_name).find_or_new
      redefine_method(method)
      method
    end

    def method_added(method_name)
      redefine_method(find(method_name))

      super
    end

    def redefine_method(method)
      return if !method || method.locked? || !method_defined?(method.name) || method_defined?(method.alias)

      method.lock! && alias_method(method.alias, method.name)

      define_method(method.name) do |&block|
        method.execute(:before, self)
        return_value = method.execute(:around, self) { send(method.alias) }
        return_value = method.execute(:proxy, return_value, &block)
        method.execute(:after, self)
        return_value
      end

      method.unlock!
    end
  end
end
