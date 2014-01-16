load "#{Rails.root}/lib/pkt_development.rb"

# get the knowledge base with label pkt
k = PKT::KnowledgeBase.instance :pkt

# add the rules to the system
k.add_rules
#
## assert facts from the parameters
## k.assert_facts_from_params params
#
## get the next rule
rule = k.current_rule







#
#
#
#class Foo
#
#
#
#end
#
#if defined? ActionController::Base
#  ActionController::Base.class_eval do
#    include CanCan::ControllerAdditions
#  end
#end


# when next_question is called from a controller
#PKT::KnowledgeBase.init

# when gem is included, code executes




#k = PKT::KnowledgeBase.new
#
## create rules using yml file
## should also be handled by an initializer and a config file
#PKT::RuleParser.yml "#{Rails.root}/rules.yml", k
#
## get all the possible rules based on known facts and rules
#rules = k.possible_rules
#
## assert the facts of the rule
#rules[0].assert_facts k

