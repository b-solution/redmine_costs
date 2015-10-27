require_dependency 'projects_controller'

module  RedmineCost
  module ProjectsControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :get_total_cost, only: [:show]
        def get_total_cost
          cond = @project.project_condition(@project.herit_cost)
          @total_cost = CostEntry.visible.where(cond).sum(:costs).to_f
        end
      end
    end

  end
  module ClassMethods


  end

  module InstanceMethods

  end

end