# TODO: data validation of the yml file, input text cannot be empty for example! and numbers etc
# TODO: refactor code so predicates like equals() are classes
# TODO: refactor goal to action / result
# TODO: when goal is rendered show decision tree
# TODO: printing of facts in questions / goal statement
# TODO: when fact already exists and new value is assigned MODIFY the fact, do not assert new one
# TODO: should have a initializer for loading the rules in the database AND for configuration
# TODO: convert to gem and add install rake task
# TODO: the generator task should create a initializer with configuration + a rules directory in the app directory with a rules.yml file

module PKT

  class KnowledgeBase < Ruleby::Rulebook

    # add class level methods for creating the Ruleby engine
    extend Ruleby

    # cattr is class level variables
    # mattr is module level variables
    # stores all the instances of the knowledge base in a hash
    cattr_accessor :instances
    @@instances = {}

    # method which passes a block, to configure the Knowledgebase
    # maybe instead of returning an instance, return a hash. Because now each time an instance gets created
    def self.setup(knowledge_base_label)

      # the argument passed in the block is the KnowledgeBase class
      yield instance(knowledge_base_label)

    end

    # get the knowledge base with the specified label
    def self.instance(label)

      # create or retrieve the knownledge base with the specified label
      @@instances[label] ||= KnowledgeBase.new label

    end

    public

    # all the rules that are already triggered
    attr_accessor :triggered_rules

    private

    # flag if the engine has already run the match method
    attr_accessor :engine_has_matched

    # one or more yml locations
    attr_accessor :yml_locations

    # instance level variable
    attr_accessor :question_rules

    # stores the results
    attr_accessor :result_rules

    # array for rules to start with
    attr_accessor :start_rules

    # stores all the rules
    attr_accessor :rules

    public

    # create a new knowledge base
    def initialize(label)

      # pass a new engine with name :knowledge_base_engine to the super class
      super KnowledgeBase::engine label

      # instantiate variables
      @engine_has_matched = false
      @yml_locations = nil

      @question_rules = Array.new
      @result_rules = Array.new
      @fact_rules = Array.new
      @triggered_rules = Array.new
      @start_rules = Array.new
      @rules = {}

    end

    # read the yml files and add rules to the knowledge base using the parser
    def add_rules

      raise 'Not a single yml location is defined for rules' if yml.empty?

      yml.each do |location|

        RuleParser.yml location, self

      end

    end

    # add a rule to the knowledge base
    def add_rule(rule_object)

      # store the rule
      @rules[rule_object.name] = rule_object

      case

        # rule which asserts facts without conditions or questions
        when rule_object.matcher.nil? && rule_object.questions.empty?

          # add the rule to the fact rules array, contains rules with only facts
          @fact_rules << rule_object

        when rule_object.matcher.nil? && rule_object.questions.count > 0

          # rules can be triggered directly
          @start_rules << rule_object

        else

          # get the matcher
          matcher = rule_object.matcher

          # get the matcher type (any / all)
          matcher_type = matcher.type

          # generate the ruleby conditions based on the matcher conditions
          conditions = create_conditions matcher.conditions

          # switch statement for the matcher type
          case matcher_type

            # all the conditions must match
            when :all

              # star to convert array to arguments
              rule AND *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_handler rule_object

              end

            # one of the conditions must match
            when :any

              # star to convert array to arguments
              rule OR *conditions do |v|

                # when rule is applicable, add to possible rules
                rule_handler rule_object

              end

            else
              raise "Unknown matcher type #{matcher.type}"

          end

      end

    end

    # add one or multiple yml locations
    def yml

      # return @yml_locations OR return an empty array and store this array in @yml_locations
      @yml_locations ||= []

    end

    # update knowledge base from the params hash
    def update_from_params(params)

      if params.has_key? :triggered_rules

        # all the posted triggered rules
        posted_triggered_rules = triggered_rules_from_encrypted(params[:triggered_rules])

        # trigger all the triggered rules?
        posted_triggered_rules.each do |rule|

          # trigger all the previous triggered rules
          trigger rule

        end

      end

      # do some checks for stuff needed in the params
      if params.has_key? :current_rule

        # get the posted rule
        posted_rule = retrieve_rule(params[:current_rule])

        # get the posted facts
        posted_facts = facts_from_params params

        # add the facts to the posted rule
        posted_rule.facts.concat posted_facts

        # trigger the posted rule
        trigger posted_rule

      end

      # TODO: set the engine_match boolean to false??

    end

    # get the next rule
    def current_rule

      # start the matching of the ruleby engine if not yet called
      unless @engine_has_matched

        # first assert all the facts from the fact rules
        # these are rules without conditions and only facts
        # when doing this while adding the rules something weird happens and instead of 1 match, stuff matches 22+ times
        @fact_rules.each do |rule|

          trigger rule

        end

        # add start rules to the question rules when they are not yet handled
        @start_rules.each do |rule|

          # when rule not yet triggered
          unless triggered? rule

            # add to the possible questions
            @question_rules << rule

          end

        end

        # match the rules using the ruleby engine
        @engine.match

        # set the matched flag
        @engine_has_matched = true

      end

      # get the first of the question rules
      @question_rules.first

    end

    # get all the result rules
    def result

      # start the matching of the ruleby engine if not yet called
      unless @engine_has_matched
        @engine.match
        @engine_has_matched = true
      end

      # return the result array
      @result_rules

    end

    # retrieve a rule created defined as defined in the yml file
    def retrieve_rule(rule_name)

      # convert to symbol
      rule_name = rule_name.to_sym

      # raise error if rule doesn't exist
      raise "Rule with name '#{rule_name}' doesn't exist" unless @rules.has_key? rule_name

      # return the rule
      @rules[rule_name]

    end

    # retrieve a fact asserted in the knowledge base
    def retrieve_fact(fact_name)

      facts = engine.retrieve Fact

      facts = facts.select { |fact| fact.name == fact_name }

      raise "Fact with name #{fact_name} is unknown or not yet asserted." if facts.empty?

      raise "There is more than 1 fact (#{facts.count} total) with name #{fact_name}" if facts.count > 1

      # return single fact
      facts.first

    end

    # return a hash of the triggered rules
    def triggered_rules_to_encrypted

      # TODO: add encryption

      # instantiate array
      array = []

      @triggered_rules.each do |rule|

        # create a new hash
        hash = {:name => rule.name, :facts => []}

        # get the facts added by the rule
        facts = rule.facts

        # iterate all the facts
        facts.each do |fact|

          hash[:facts] << {:name => fact.name, :value => fact.value}

        end

        # add the hash to the array
        array << hash

      end

      # return the encrypted array
      string = array.to_json

      # encrypt the data
      encrypted = string

    end

    # get triggered rules from the hash
    def triggered_rules_from_encrypted(encrypted)

      # TODO: add decryption

      # create a new rules array
      rules = Array.new

      # decrypt the data
      string = encrypted

      # get the array back
      array = JSON.parse string

      # iterate the array
      array.each do |hash|

        # get the rule back
        rule = retrieve_rule hash['name']

        # create a new facts array
        facts = []

        # retrieve each of the facts
        hash['facts'].each do |fact|

          # create a new fact for each
          facts << create_fact(fact['name'], fact['value'])

        end

        # replace the facts on the rule
        rule.facts = facts

        # add to the array
        rules << rule

      end

      # return the rules array
      rules

    end

    # method for creating facts
    def create_fact(name, value)

      Fact.new name, convert_variable(value)

    end

    private

    # get the facts posted
    def facts_from_params(params)

      facts = []

      params.each do |name, value|

        if is_fact? name

          facts << create_fact(name, value)

        end

      end

      # return facts
      facts

    end

    # gets called when the conditions of a rule match
    def rule_handler(rule_object)

      # only rules that are not yet triggered should be processed
      unless triggered? rule_object

        case

          # when there are no questions and no goals
          when rule_object.questions.empty? && rule_object.goal.nil?

            # trigger the rule, thus asserting facts and storing in triggered rules
            trigger rule_object

          # when the goal is NOT nil
          when !rule_object.goal.nil?

            # add to the result rules
            @result_rules << rule_object

          # otherwise add to the question rules
          else

            # add to the possible questions
            @question_rules << rule_object

        end

      end

    end

    # assert all the facts stored in a rule
    def assert_facts_from_rule(rule_object)

      # get the facts from the rule
      facts = rule_object.facts

      # iterate all the facts
      facts.each do |fact|

        # evaluate fact value
        # TODO: ONLY evaluate fact when trigger is called on a top level rule fact
        fact.value = evaluate_fact_value fact.value

        # let the ruleby engine assert the fact
        @engine.assert fact

      end

    end

    # evaluates the value of the fact
    def evaluate_fact_value(value)

      # only when the type of the value is a string
      if value.is_a? String

        # replace each fact name with the value of that fact
        k = value.gsub(/\$[a-zA-Z0-9]+/) { |match|

          # get the fact from the knowledge base
          fact = retrieve_fact match

          # return the value of the fact
          fact.value

        }

        # TODO: eval is security risk, create sandbox? or allow less operators?
        value = eval(k)

      end

      # return the value
      value

    end

    # trigger a rule, asserting the facts and adding to the triggered_rules
    def trigger(rule_object)

      # only when not yet triggered trigger the rule
      unless triggered? rule_object

        # assert all the facts stored in the rule
        assert_facts_from_rule rule_object

        # add the rule to the triggered rules
        @triggered_rules << rule_object

      end

    end

    # determine if rule is already triggered
    def triggered? (rule_object)

      # check if the rule is in the triggered rules array
      triggered_rules.include? rule_object

    end

    # map actual conditions to the triplets passed here
    def create_conditions(conditions)

      conditions.map { |item| create_condition item }

    end

    # create and return a condition
    def create_condition(item)

      var1 = convert_variable(item[0])
      var2 = convert_variable(item[2])

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

    # TODO: what about floats?
    def convert_variable var

      # if it returns nil, it is a string
      if /^[0-9]+$/.match(var).nil?

        var

      else # otherwise it is a integer, so convert to integer

        var.to_i

      end

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

    #def assert(knowledge_base)
    #
    #  # evaluate the value of the fact, can contain arithmetic
    #  if @value.is_a? String
    #
    #    k = @value.gsub(/\$[a-zA-Z0-9]+/) { |match|
    #
    #      # get the fact from the knowledge base
    #      fact = knowledge_base.retrieve_fact match
    #
    #      # return the value of the fact
    #      fact.value
    #
    #    }
    #
    #
    #    @value = eval(k)
    #
    #  end
    #
    #  knowledge_base.assert self
    #
    #end

  end

end