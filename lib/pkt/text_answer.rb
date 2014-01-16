module PKT

  class TextAnswer < Answer

    attr_accessor :fact_name

    def initialize(content)

      self.fact_name = content

    end

  end

end