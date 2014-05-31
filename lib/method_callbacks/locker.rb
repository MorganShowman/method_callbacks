module MethodCallbacks
  class Locker
    attr_accessor :state

    def initialize
      self.state = :unlocked
    end

    def lock!
      self.state = :locked
    end

    def locked?
      state == :locked
    end

    def unlock!
      self.state = :unlocked
    end
  end
end
