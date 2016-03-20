require_dependency 'project_enumerations_controller'

module  RedmineCost
  module ProjectEnumerationsControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do

      end
    end

  end
  module ClassMethods


  end

  module InstanceMethods
    def update_cost_entry
      if request.post? && params[:enumerations]
        Project.transaction do
          params[:enumerations].each do |id, activity|
            @project.update_or_create_cost_entry_activity(id, activity)
          end
        end
        flash[:notice] = l(:notice_successful_update)
      end

      redirect_to settings_project_path(@project, :tab => 'cost_activities')
    end

    def destroy_cost_entry
      @project.cost_entry_activities.each do |cost_entry_activity|
        cost_entry_activity.destroy(cost_entry_activity.parent)
      end
      flash[:notice] = l(:notice_successful_update)
      redirect_to settings_project_path(@project, :tab => 'cost_activities')
    end
  end

end