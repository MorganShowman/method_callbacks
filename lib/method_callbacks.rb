require "method_callbacks/finder"
require "method_callbacks/version"

module MethodCallbacks
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def after_method(method_name, *callback_names)
      __method_callbacks_define(method_name, :after, callback_names)
      __method_callbacks_define_with_block(method_name, :after, &Proc.new) if block_given?
    end

    def around_method(method_name, *callback_names)
      __method_callbacks_define(method_name, :around, callback_names)
    end

    def proxy_result(method_name, &block)
      __method_callbacks_define_with_block(method_name, :proxy, &block)
    end

    def before_method(method_name, *callback_names)
      __method_callbacks_define(method_name, :before, callback_names)
      __method_callbacks_define_with_block(method_name, :before, &Proc.new) if block_given?
    end

    private

    def __method_callbacks_define(method_name, type, callback_names)
      __method_callbacks_find_or_new(method_name).define(type, callback_names)
    end

    def __method_callbacks_define_with_block(method_name, type)
      __method_callbacks_find_or_new(method_name).define_with_block(type, &Proc.new)
    end

    def __method_callbacks_find(method_name)
      __method_callbacks_finder(method_name).find
    end

    def __method_callbacks_finder(method_name)
      @___method_callbacks_finder ||= {}
      @___method_callbacks_finder[method_name] ||= MethodCallbacks::Finder.new(method_name)
    end

    def __method_callbacks_find_or_new(method_name)
      method = __method_callbacks_finder(method_name).find_or_new
      __method_callbacks_redefine_method(method)
      method
    end

    def __method_callbacks_method_added(method_name)
      __method_callbacks_redefine_method(find(method_name))

      super
    end

    def __method_callbacks_redefine_method(method)
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
