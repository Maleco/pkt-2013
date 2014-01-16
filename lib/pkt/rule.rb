module PKT

  # TODO: goals cannot have facts
  # TODO: goals cannot have questions
  # TODO: rule needs to have at least 1 fact OR 1 goal OR 1 question

  class Rule

    attr_accessor :name, :questions, :goal, :facts

    def initialize(name)

      self.name      = name.to_sym
      self.questions = Array.new
      self.facts     = Array.new

    end

    def matcher=(value)

      # raise error when matcher already set
      raise "Matcher already set #{self.inspect}" unless @matcher.nil?

      @matcher = value

    end

    def matcher

      @matcher

    end

  end

end
