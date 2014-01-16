module PKT

  class CheckboxAnswer < Answer

    attr_accessor :options

    def initialize (content)

      @options = content

    end

  end

end