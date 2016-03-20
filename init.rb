Redmine::Plugin.register :redmine_costs do
  name 'Redmine Costs plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/bilel-kedidi/redmine_cost'
  author_url 'http://github.com/bilel-kedidi'

  settings :default => {
               'currency' => 'Currency'
           }
  project_module :redmine_costs do
    permission :edit_own_cost_entries, :cost_entry => ['index', 'report', 'edit', 'update', 'destroy']
    permission :log_cost, :cost_entry => ['new', 'create']
  end

end


Rails.application.config.to_prepare do
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_projects_show_sidebar_bottom, :partial=> 'redmine_cost/show_overview'
    render_on :view_issues_show_details_bottom, :partial=> 'redmine_cost/show_overview_issue'
  end
  ApplicationHelper.send(:include, RedmineCost::ApplicationHelperPatch)
  ProjectsHelper.send(:include, RedmineCost::ProjectsHelperPatch)
  Project.send(:include, RedmineCost::ProjectPatch)
  TimeEntry.send(:include, RedmineCost::TimeEntryPatch)
  Enumeration.send(:include, RedmineCost::EnumerationPatch)
  ProjectsController.send(:include, RedmineCost::ProjectsControllerPatch)
  MyController.send(:include, RedmineCost::MyControllerPatch)
  MyHelper.send(:include, RedmineCost::MyHelperPatch)
  ProjectEnumerationsController.send(:include, RedmineCost::ProjectEnumerationsControllerPatch)
end