module PKT

  module ViewAdditions

    module ClassMethods

    end

    module InstanceMethods

      # render the hidden input fields for determining past / current rules
      def knowledge_base_fields

        # get the knowledge base
        # TODO: should not hardcode the label
        k = PKT::KnowledgeBase.instance :pkt

        # render an hidden_field_tag with the current rule
        rule = k.current_rule

        # get the triggered rules
        rules = k.triggered_rules_to_encrypted

        # render an hidden field with the current rule
        output = hidden_field_tag(:current_rule, rule.name)

        # render an hidden field with the previous rules
        output += hidden_field_tag(:triggered_rules, rules)

      end

    end

    def self.included(base)

      base.send :include, InstanceMethods
      base.extend ClassMethods

    end

  end

end

if defined? ActionView::Base
  ActionView::Base.class_eval do

    include PKT::ViewAdditions

  end
end