module PKT

  # TODO: throw error on the same goal or rule name
  # TODO: central place with regular expressions what characters a fact / arithmetic / ... can contain
  # TODO: better handling of types! maybe label a fact with of some sort that is read by the knowledge base? eval()?
  class RuleParser

    def self.yml(location, knowledge_base)

      # load the yml file
      yml_config = YAML.load_file(location)

      # iterate each of the yml items
      yml_config.each do |rule_name, rule_content|

        # create the rule object
        rule = PKT::Rule.new rule_name

        # raise error if isn't iteratable?
        raise "Error in rule #{rule_name}: #{rule_content} does not contain any further definitions" unless rule_content.respond_to? :each

        # iterate the yml rule content
        rule_content.each do |name, value|

          case

            when value.nil?
              raise "Error in rule #{rule_name}: the content of #{name} is nill"

            when name == 'any'

              # it's an any matcher
              # always followed by an array of conditions
              matcher = Matcher.new :any

              # add the conditions
              add_conditions_to_matcher value, matcher

              # add the matcher to the rule
              rule.matcher = matcher

            when name == 'all'
              # it's an all matcher
              # always followed by an array of conditions
              matcher = Matcher.new :all

              # add the conditions
              add_conditions_to_matcher value, matcher

              # add the matcher to the rule
              rule.matcher = matcher

            when name == 'goal' # it's a goal -> can't contain questions AND facts

              # fill in the goal variable
              rule.goal = value

            when name[0] == '$' # it's a fact

              # create a fact and add it to the rule
              rule.facts << knowledge_base.create_fact(name, value)

            else # it's a question

              # create a new question
              question = Question.new name

              # question can only contain single answer method
              value.each do |answer_method, answer_content|

                case answer_method

                  when 'text'

                    question.answer = TextAnswer.new answer_content

                  when 'radio'

                    question.answer = RadioAnswer.new answer_content

                  when 'checkbox'

                    question.answer = CheckboxAnswer.new answer_content

                  else
                    raise "Error in rule #{rule_name}: unknown answer method #{answer_method}"
                end

              end

              rule.questions << question

          end

        end

        # add the rule to the database
        knowledge_base.add_rule rule

      end

    end

    private

    def self.add_conditions_to_matcher(conditions, matcher)

      conditions.each do |condition|

        result = parse_condition condition

        case result[:operation]

          when 'equals'
            matcher.equals(result[:var1], result[:var2])

          when 'less'
            matcher.less(result[:var1], result[:var2])

          when 'greater'
            matcher.greater(result[:var1], result[:var2])

          when 'has'
            matcher.has(result[:var1])

          else
            raise "Unknown operation '#{result[:operation]}' in condition '#{condition}'"
        end

      end

    end

    def self.parse_condition (condition)

      result = /(?<operation>[a-zA-Z]+)\s*\(\s*(?<var1>[a-zA-Z0-9$]+)\s*(,\s*(?<var2>[a-zA-Z0-9$]+)\s*)?\)/.match(condition)

      raise "Syntax error in condition: #{condition}" if result.nil?

      {:var1 => result[:var1], :var2 => result[:var2], :operation => result[:operation]}

    end

  end

end