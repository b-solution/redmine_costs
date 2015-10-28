require_dependency 'time_entry'

module  RedmineCost
  module TimeEntryPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        after_save :set_project_cost
        def set_project_cost
          ProjectCost.create_or_update_cost_entry(self)
        end
      end
    end

  end
  module ClassMethods


  end

  module InstanceMethods

  end

end