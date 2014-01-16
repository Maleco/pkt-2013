module PKT

  class RadioAnswer < Answer

    attr_accessor :fact_name, :options

    def initialize (content)

      content.each do |name, value|

        # todo: implement proper handling of the content

        @fact_name = name
        @options   = value

      end

    end

  end

end