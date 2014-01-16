class PagesController < ApplicationController

  def home

    # TODO: this temporarily should be removed when converted to a gem
    load "#{Rails.root}/lib/pkt_development.rb"

    # get a knowledge base with specified label
    k = knowledge_base :pkt

    # add the rules from the yml files
    k.add_rules

    # assert facts from the parameters
    k.update_from_params params

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

  end

end
