class Rule

  attr_accessor :name, :questions, :matcher, :is_goal

  def initialize(name, is_goal = false)

    self.name      = name.to_sym
    self.questions = Array.new
    self.is_goal   = is_goal

  end

end

class Question

  attr_accessor :content, :answer

  def initialize(content)

    self.content = content

  end

end

class Answer

end

class TextAnswer < Answer

  attr_accessor :fact_name

  def initialize(fact_name)

    self.fact_name = fact_name

  end

end

class Matcher

  attr_accessor :type, :conditions

  def initialize(type)

    self.type       = type
    self.conditions = Array.new

  end

  def equals variable1, variable2

    self.conditions << [variable1, :==, variable2]

  end

end

class Fact
  attr_accessor :name, :value

  def initialize(name, value)
    self.name  = name
    self.value = value
  end
end

class KnowledgeBase < Ruleby::Rulebook

  # add class level methods for creating the Ruleby engine
  extend Ruleby

  def initialize

    super KnowledgeBase::engine :knowledge_base_engine

  end

  def add_rule(rule_object)

    # get the matcher
    matcher      = rule_object.matcher

    # get the matcher type (any / all)
    matcher_type = matcher.type

    # generate the ruleby conditions based on the matcher conditions
    conditions   = create_conditions matcher.conditions

    # star to convert array to arguments
    rule *conditions do |v|

      # when rule is applicable, add to global ? array with possible rules

      puts 'TRIGGERED!!'

    end

    # switch statement for the matcher type
    case matcher.type

      when :all # all the conditions must match


      when :any # one of the conditions must match


      else
        raise "Unknown matcher type #{matcher.type}"

    end

  end

  # call this function to get all the possible rules
  # this is based on all the asserted facts and rules known
  def possible_rules

    # start the matching of the engine
    @engine.match

  end

  private

  def create_conditions(conditions)

    conditions.map { |item| create_condition item }

  end

  def create_condition(item)

    var1     = item[0]
    var2     = item[2]
    operator = item[1]

    if is_fact?(var1) && is_fact?(var2)

      return [
          [Fact, :f1, m.name == var1, {m.value => :f1_value}],
          [Fact, :f2, m.name == var2, operation(m.value, operator, b(:f1_value))]
      ]

    end

    if is_fact?(var1) && !is_fact?(var2)

      return [Fact, :f1, m.name == var1, m.value == var2]

    end

    if !is_fact?(var1) && is_fact?(var2)

      return [Fact, :f1, m.name == var2, m.value == var1]

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

end

class RuleParser

  class << self

    def yml location, knowledge_base

      # load the yml file
      # create rules from the yml file like so:
      # maybe instead of objects, use a hash?

      yml_config = YAML.load_file(location)

      yml_config.each do |rule_name, rule_content|

        rule_content.each do |name, value|

          case name

            when 'any' # it's an any matcher


            when 'all' # it's an all matcher


            when 'goal' # it's a goal -> can't contain questions AND facts


            when name[0] == '$' # it's a fact


            else # it's a question

          end

        end

      end


      # when there is a goal setting, raise error when there are questions










      ## create the rule
      #rule            = Rule.new 'rule1'
      #
      ## create a new question for each question asked
      #question        = Question.new 'wat is de temperatuur?'
      #
      ## set the answering type for the question
      #question.answer = TextAnswer.new('temperature')
      #
      ## add the question to the rule
      #rule.questions << question
      #
      ## create a new condition object
      #matcher = Matcher.new :all
      #
      ## fact :something == 1
      #matcher.equals ':something', '1'
      #
      ## set the condition on the rule
      #rule.matcher = matcher
      #
      ## add a rule to the knownledge base
      #knowledge_base.add_rule rule

    end

    def is_question?(value)

      case value
        when 'any'
        when 'all'


      end

    end

  end

end

# instantiate the knowledge base
k = KnowledgeBase.new

# parse the yml file and create rules in the knowledge base
RuleParser.yml("#{Rails::root}/own_rules.yml", k)

# add all the facts known (passed in the form)
k.assert Fact.new ':something', '1'

# get all the possible rules based on known facts and rules
rules = k.possible_rules