class ProjectCostController < ApplicationController
  unloadable


  def set_costs
    @project = Project.find(params[:project_id])
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
    redirect_to :back
  end
end
