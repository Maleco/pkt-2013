module PKT

  class Matcher

    attr_accessor :type, :conditions

    def initialize(type)

      self.type       = type
      self.conditions = Array.new

    end

    def has var1

      self.conditions << [var1, :has, nil]

    end

    def equals var1, var2

      self.conditions << [var1, :==, var2]

    end

    def less var1, var2

      self.conditions << [var1, :<, var2]

    end

    def greater var1, var2

      self.conditions << [var1, :>, var2]

    end

  end

end