module PKT

  class Answer

    def template

      # TODO: implement better method of handling rendering the questions / answers
      template = self.class.to_s.underscore

    end

  end

end