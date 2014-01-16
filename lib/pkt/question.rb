module PKT

  class Question

    attr_accessor :content, :answer

    def initialize(content)

      self.content = content

    end

    def answer=(value)

      # raise error when answer already set
      raise "Question answer already set: #{@answer.inspect} on question #{self.inspect}" unless @answer.nil?

      @answer = value

    end

    def answer

      raise "Answer not set on question #{self.inspect}" if @answer.nil?

      @answer

    end

  end

end