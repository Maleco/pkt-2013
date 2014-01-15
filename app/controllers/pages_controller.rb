class PagesController < ApplicationController

  def home

    # TODO: this temporarily should be removed when converted to a gem
    load "#{Rails.root}/lib/pkt_development.rb"

    # get a knowledge base with specified label
    k = knowledge_base :pkt

    # add the rules from the yml files
    k.add_rules

    # assert facts from the parameters
    k.assert_facts_from_params params

    # get the current rule
    @rule = k.current_rule

    # if there is no next rule, render result
    if @rule.nil?

      # get the possible result rules
      @results = k.result

      # render the result page
      render :result

    else

      render :rule

    end



    ## TODO: move a lot of this code into the knowledge base class
    ## TODO: all the rules that 'fired' should be in a hash/array with all the facts + values associated with that rule
    ## TODO: this includes facts asserted directly when the rule is chosen
    #
    ## instantiate the knowledge base
    #k = PKT::KnowledgeBase.new
    #
    ## parse the yml file and create rules in the knowledge base
    #PKT::RuleParser.yml("#{Rails::root}/rules.yml", k)
    #
    ## get the previous answered rules
    #answered_rules = answered_rules_from_params
    #
    ## if there is a new rule posted, add it to the answered rules
    #unless params[:current_rule].nil?
    #
    #  # get the rule posted, strong parameters posts everything in hashes :/
    #  # TODO: change the parameter is handled, not hash
    #  posted_rule = params[:current_rule].keys[0]
    #
    #  # get the facts posted by the rule
    #  facts = facts_from_params
    #
    #  # add the current rule and facts to the answered rules
    #  answered_rules[posted_rule] = facts
    #
    #end
    #
    ## assert the newly posted facts
    #assert_facts_from_rules answered_rules, k
    #
    ## get all the possible rules based on known facts and rules
    #rules = k.question_rules
    #
    ## remove the rules that already have been answered
    #rules = remove_answered_rules rules, answered_rules
    #
    ## there are no possible rules
    #if rules.count > 0
    #
    #  # create instance variable for rendering
    #  # get the first NON goal rule?
    #  @rule = rules[0]
    #
    #  # assert the facts associated with the rule
    #  # TODO: should be handled by the knowledge base class
    #  @rule.assert_facts k
    #
    #  # update the instance variable answered
    #  @answered_data = answered_rules
    #
    #  # get the first rule and render
    #  render :rule
    #
    #else
    #
    #  # get the goals
    #  @goals = k.goals
    #
    #  # render the goal view
    #  render :result
    #
    #end

  end

  private

  def answered_rules_from_params

    if params[:answered].nil?
      HashWithIndifferentAccess.new
    else

      decoded = JSON.parse(params[:answered])

      HashWithIndifferentAccess.new decoded
    end

  end

  def assert_facts_from_rules rules, knowledge_base

    rules.each do |rule_name, facts|

      facts.each do |fact|

        knowledge_base.assert PKT::Fact.new(fact[:name], convert_variable(fact[:value]))

      end

    end

  end

  def convert_variable var

    # if it returns nil, it is a string
    if /^[0-9]+$/.match(var).nil?

      var

    else # otherwise it is a integer

      var.to_i

    end

  end

  def facts_from_params

    facts = []

    params.each do |name, value|

      if name[0] == '$'

        facts << {:name => name, :value => value}

      end

      if name == 'checkbox'

        value.each do |name, value|

          if name[0] == '$'

            facts << {:name => name, :value => value}

          end

        end

      end

    end

    # return facts
    facts

  end

  def remove_answered_rules rules, answered_rules

    rules.reject { |rule|
      answered_rules.has_key? rule.name
    }

  end

end
