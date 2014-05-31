require "method_callbacks/finder"
require "method_callbacks/version"

module MethodCallbacks
  ALIAS_PREFIX = "__method_callback_alias_to_original"

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
      finder(method_name).find_or_new
    end

    def method_added(method_name)
      redefine_method(find(method_name))

      super
    end

    def redefine_method(method)
      return if !method || method.locked?

      method.lock! && alias_method("#{ALIAS_PREFIX}_#{method.name}", method.name)

      define_method(method.name) do
        method.execute(:before, self)
        return_value = method.execute(:around, self) do
          send("#{ALIAS_PREFIX}_#{method.name}")
        end
        method.execute(:after, self)
        return_value
      end

      method.unlock!
    end
  end
end
