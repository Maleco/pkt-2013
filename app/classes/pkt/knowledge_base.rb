# TODO: data validation of the yml file, input text cannot be empty for example! and numbers etc
# TODO: refactor goals to results / actions
# TODO: refactor code so predicates like equals() are classes
# TODO: refactor goal to action / result
# TODO: when goal is rendered show decision tree
# TODO: introduce concept of Question Rule / Goal Rule and Fact Rule
# TODO: printing of facts in a goal statement
# TODO: when fact already exists and new value is assigned MODIFY the fact, do not assert new one

module PKT

  class KnowledgeBase < Ruleby::Rulebook

    # add class level methods for creating the Ruleby engine
    extend Ruleby

    attr_accessor :possible_rules

    def next_question

    #  TODO: return the next question or nil if there aren't any questions left

    end

    def initialize

      # pass a new engine with name :knowledge_base_engine to the super class
      super KnowledgeBase::engine :knowledge_base_engine

      # instantiate the possible rules array
      @possible_rules = Array.new

    end

    def add_rule(rule_object)

      case

        # rule which asserts facts without conditions or questions
        when rule_object.matcher.nil? && rule_object.questions.empty?

          # assert all the facts
          rule_object.assert_facts self

        when rule_object.matcher.nil? && rule_object.questions.count > 0

          # rule can be fired directly
          @possible_rules << rule_object

        else

          # get the matcher
          matcher      = rule_object.matcher

          # get the matcher type (any / all)
          matcher_type = matcher.type

          # generate the ruleby conditions based on the matcher conditions
          conditions   = create_conditions matcher.conditions

          # switch statement for the matcher type
          # TODO: implement matcher types
          case matcher_type

            when :all # all the conditions must match

              # star to convert array to arguments
              rule AND *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_triggered rule_object

              end

            when :any # one of the conditions must match

              # star to convert array to arguments
              rule OR *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_triggered rule_object

              end

            else
              raise "Unknown matcher type #{matcher.type}"

          end

      end

    end

    def retrieve_fact(fact_name)

      facts = engine.retrieve Fact

      facts = facts.select{ |fact| fact.name == fact_name }

      raise "Fact with name #{fact_name} is unknown or not yet asserted." if facts.empty?

      raise "There is more than 1 fact (#{facts.count} total) with name #{fact_name}" if facts.count > 1

      # return single fact
      facts[0]

    end

    def rule_triggered(rule_object)

      # if the rule only contains facts and no questions assert all the facts immediatly
      if rule_object.questions.empty? && rule_object.goal.nil?

        # assert the facts associated with the rule object
        rule_object.assert_facts self

      else

        # add the rule object to the possible_rules array
        @possible_rules << rule_object

      end

    end

    # call this function to get all the possible rules
    # this is based on all the asserted facts and rules known
    def possible_rules

      # start the matching of the engine
      @engine.match

      # reject all rules that ARE goals and return the result
      @possible_rules.reject { |rule| !rule.goal.nil? }

    end

    def goals

      # reject all the rules that are NOT goals
      @possible_rules.reject { |rule| rule.goal.nil? }

    end

    private

    def create_conditions(conditions)

      conditions.map { |item| create_condition item }

    end

    def create_condition(item)

      var1     = convert_variable(item[0])
      var2     = convert_variable(item[2])
      operator = item[1]

      if is_fact?(var1) && is_fact?(var2)

        return [AND(
                    [Fact, :f1, m.name == var1, {m.value => :f1_value}],
                    [Fact, :f2, m.name == var2, operation(m.value, operator, b(:f1_value))]
                )]

      end

      if is_fact?(var1) && !is_fact?(var2)

        return [Fact, :f1, m.name == var1, operation(m.value, operator, var2)]

      end

      if !is_fact?(var1) && is_fact?(var2)

        return [Fact, :f1, m.name == var2, operation(m.value, operator, var1)]

      end

      raise "There is no fact name in: #{var1} #{operator} #{var2}"

    end

    def operation(var1, operator, var2)

      case operator
        when :==
          var1 == var2
        when :>
          var1 > var2
        when :<
          var1 < var2
        when :has
          # TODO: other way conditions are handled!
          var1
        else
          raise "Unknown operator #{operator}"

      end

    end

    def is_fact? variable

      # only works on strings
      if variable.is_a? String

        return variable[0] == '$'

      end

      # otherwise return false
      false

    end

    def convert_variable var

      # if it returns nil, it is a string
      if /^[0-9]+$/.match(var).nil?

        var

      else # otherwise it is a integer

        var.to_i

      end

    end

  end

end