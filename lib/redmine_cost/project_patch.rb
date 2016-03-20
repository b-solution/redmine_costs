module  RedmineCost
  module ProjectPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        has_many :cost_entry_activities
      end
    end

  end
end
module ClassMethods


end

module InstanceMethods
  def active_cost_entry_activities
    overridden_activity_ids = self.cost_entry_activities.collect(&:parent_id)

    if overridden_activity_ids.empty?
      return CostEntryActivity.shared.active
    else
      return system_cost_entries_activities_and_project_overrides
    end
  end

  def activities_for_cost_entry(include_inactive=false)
    overridden_activity_ids = cost_entry_activities.collect(&:parent_id)

    if overridden_activity_ids.empty?
      CostEntryActivity.shared
    else
      system_cost_entries_activities_and_project_overrides(true)
    end
  end

  def system_cost_entries_activities_and_project_overrides(include_inactive=false)
    t = CostEntryActivity.table_name
    scope = CostEntryActivity.where(
        "(#{t}.project_id IS NULL AND #{t}.id NOT IN (?)) OR (#{t}.project_id = ?)",
        cost_entry_activities.map(&:parent_id), id
    )
    unless include_inactive
      scope = scope.active
    end
    scope
  end

  def update_or_create_cost_entry_activity(id, activity_hash)
    if activity_hash.respond_to?(:has_key?) && activity_hash.has_key?('parent_id')
      self.create_cost_entry_activity_if_needed(activity_hash)
    else
      activity = project.cost_entry_activities.find_by_id(id.to_i)
      activity.update_attributes(activity_hash) if activity
    end
  end

# Create a new TimeEntryActivity if it overrides a system TimeEntryActivity
#
# This will raise a ActiveRecord::Rollback if the TimeEntryActivity
# does not successfully save.
  def create_cost_entry_activity_if_needed(activity)
    if activity['parent_id']
      parent_activity = CostEntryActivity.find(activity['parent_id'])
      activity['name'] = parent_activity.name
      activity['position'] = parent_activity.position
      if Enumeration.overriding_change?(activity, parent_activity)
        project_activity = self.cost_entry_activities.create(activity)
        if project_activity.new_record?
          raise ActiveRecord::Rollback, "Overriding TimeEntryActivity was not successfully saved"
        else
          self.time_entries.
              where(["activity_id = ?", parent_activity.id]).
              update_all("activity_id = #{project_activity.id}")
        end
      end
    end
  end
end
