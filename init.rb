Redmine::Plugin.register :redmine_costs do
  name 'Redmine Costs plugin'
  author 'ISPEHE'
  description 'This is a plugin for Redmine'
  version '1.0.0'
  url 'http://ispehe.org/'
  author_url 'http://ispehe.org/'


  settings :default => {
               'currency' => 'Currency'
           }
  project_module :redmine_costs do
    permission :edit_own_cost_entries, :cost_entry => ['index', 'report', 'edit',
                                                       'update', 'destroy', 'bulk_update'],
               :project_enumerations => [:update_cost_entry, :destroy_cost_entry]
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

  ContextMenusController.send(:include, RedmineCost::ContextMenusControllerPatch)
end
