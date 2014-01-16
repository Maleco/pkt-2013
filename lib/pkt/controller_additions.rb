module PKT

  module ControllerAdditions

    module ClassMethods

      def class_bar

        puts 'class method'

      end

    end

    module InstanceMethods

      def knowledge_base(label)

        PKT::KnowledgeBase.instance label

      end

    end

    def self.included(base)

      # include is a private method, so use send method
      base.send(:include, InstanceMethods)

      # add class level methods
      base.extend ClassMethods

      # add some methods to the view
      # only instance methods of the controller are applicable
      # base.helper_method :instance_bar

    end

  end

end

if defined? ActionController::Base
  ActionController::Base.class_eval do

    include PKT::ControllerAdditions

  end
end