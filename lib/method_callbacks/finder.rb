require "method_callbacks/method"

module MethodCallbacks
  class Finder
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def find
      @_find ||= {}
      @_find[name] ||= methods.select { |callback| callback == self }.first
    end

    def find_or_new
      find || new
    end

    private

    def new
      method = Method.new(name)
      methods << method
      method
    end

    def methods
      @_methods ||= []
    end
  end
end
