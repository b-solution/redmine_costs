require_dependency 'my_helper'

module  RedmineCost
  module MyHelperPatch
    def self.included(base)
      base.class_eval do
        def cost_entry_items
          CostEntry.
              where("#{CostEntry.table_name}.user_id = ? AND #{CostEntry.table_name}.spent_on BETWEEN ? AND ?", User.current.id, Date.today - 6, Date.today).
              includes(:activity, :project, {:issue => [:tracker, :status]}).
              order("#{CostEntry.table_name}.spent_on DESC, #{Project.table_name}.name ASC, #{Tracker.table_name}.position ASC, #{Issue.table_name}.id ASC").
              all
        end
      end
    end
  end
end
