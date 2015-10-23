Redmine::Plugin.register :redmine_costs do
  name 'Redmine Costs plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/bilel-kedidi'
  author_url 'http://github.com/bilel-kedidi'

  project_module :redmine_cost do
    permission :edit_own_cost_entries, :cost_entry=> 'edit'
    permission :edit_cost_entries, :cost_entry=> 'edit'
    permission :view_cost_entries, :cost_entry=> 'index'
    permission :log_cost, :cost_entry=> 'new'
    permission :delete_cost, :cost_entry=> 'destroy'
  end

end


Rails.application.config.to_prepare do
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_projects_show_sidebar_bottom, :partial=> 'redmine_cost/show_overview'
  end
  ProjectsController.send(:include, RedmineCost::ProjectPatch)
end