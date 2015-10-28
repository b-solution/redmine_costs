module ProjectCostHelper
  def self.l_cost(costs, project)
    return costs unless project
    settings = Setting.send "plugin_redmine_costs"
    value = project.custom_field_values.select{|cfv| cfv.custom_field.name == settings['currency']}.first.value
    "#{costs} #{value}"
  end
end
