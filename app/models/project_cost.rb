class ProjectCost < ActiveRecord::Base
  unloadable

  def self.create_or_update_cost_entry(time_entry)
    ce = CostEntry.where(time_entry_id: time_entry.id).first_or_initialize
    ce.project_id = time_entry.project_id
    ce.issue_id = time_entry.issue_id
    ce.spent_on = time_entry.spent_on
    ce.activity_id = time_entry.activity_id
    ce.user_id = time_entry.user_id
    ce.time_entry_id = time_entry.id
    project = time_entry.project
    if project
      user = time_entry.user
      if (role = user.membership(project)).present?
        pc = ProjectCost.where(project_id: project.id).detect{|c| c.role_id = role.id}
        if pc
          ce.costs = pc.cost * time_entry.hours
          ce.save
        end
      else
        if user.admin?
          pc = ProjectCost.where(project_id: project.id).detect{|c| c.role_id = -1}
          if pc
            ce.costs = pc.cost * time_entry.hours
            ce.save
          end
        end
      end
    end
  end
end
