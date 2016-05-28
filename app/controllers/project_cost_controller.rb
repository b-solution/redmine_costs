class ProjectCostController < ApplicationController
  unloadable


  def set_costs
    @project = Project.find(params[:project_id])
    @project.herit_cost = params[:inherit_cost]
    @project.save

    costs = params['cost']
    @project.users.each do |user|
      pc = ProjectCost.where(project_id: @project.id).where(user_id: user.id).first_or_initialize
      pc.cost = costs["#{user.id}"].first.to_f.round(2)
      pc.save
    end
    update_time_entries(@project)
    redirect_to :back
  end

  def set_costs_items

  end

  private
  def update_time_entries(project)
    project.time_entries.each do |time_entry|
      ProjectCost.create_or_update_cost_entry(time_entry)
    end
  end

end
