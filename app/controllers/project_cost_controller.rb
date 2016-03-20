class ProjectCostController < ApplicationController
  unloadable


  def set_costs
    @project = Project.find(params[:project_id])
    @project.herit_cost = params[:inherit_cost]
    @project.save

    costs = params['cost']
    Role.sorted.all.each do |role|
      pc = ProjectCost.where(project_id: @project.id).where(role_id: role.id).first_or_initialize
      pc.cost = costs["#{role.id}"].first.to_f.round(2)
      pc.save
    end
    if costs["-1"].first.present?
      pc = ProjectCost.where(project_id: @project.id).where(role_id: -1).first_or_initialize
      pc.cost = costs["-1"].first.to_f.round(2)
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
