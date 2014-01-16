module PKT

  module ModelAdditions

    module ClassMethods

    end

    module InstanceMethods

    end

    def self.included(base)

      base.send :include, InstanceMethods
      base.extend ClassMethods

    end

  end

end

if defined? ActiveRecord::Base
  ActiveRecord::Base.class_eval do

    include PKT::ModelAdditions

  end
end

