require_dependency 'projects_controller'

module  RedmineCost
  module ProjectPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :get_total_cost, only: [:show]
        def get_total_cost
          cond = @project.project_condition(Setting.display_subprojects_issues?)
          if User.current.allowed_to?(:view_time_entries, @project)
            @total_cost = CostEntry.visible.where(cond).sum(:costs).to_f
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