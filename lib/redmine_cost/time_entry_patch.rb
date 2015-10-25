require_dependency 'time_entry'

module  RedmineCost
  module TimeEntryPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        after_save :set_project_cost
        def set_project_cost
          ce = CostEntry.where(time_entry_id: self.id).first_or_initialize
          ce.project_id = self.project_id
          ce.issue_id = self.issue_id
          ce.spent_on = self.spent_on
          ce.activity_id = self.activity_id
          ce.user_id = self.user_id
          project = self.project
          if project
            user = self.user
            if (role = user.membership(project)).present?
              pc = ProjectCost.where(project_id: project.id).detect{|c| c.role_id = role.id}
              if pc
                ce.costs = pc.cost * self.hours
                ce.save
              end
            else
              if user.admin?
                pc = ProjectCost.where(project_id: project.id).detect{|c| c.role_id = -1}
                if pc
                  ce.costs = pc.cost * self.hours
                  ce.save
                end
              end
            end
          end
        end
      end
    end

  end
  module ClassMethods


  end

  module InstanceMethods

  end

end