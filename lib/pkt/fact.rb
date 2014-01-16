module PKT

  class Fact

    attr_accessor :name, :value

    def initialize(name, value)

      # store the fact name
      self.name  = name

      # store the converted value
      self.value = value

    end

  end

end