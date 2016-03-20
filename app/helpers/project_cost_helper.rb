module ProjectCostHelper
  def self.l_cost(costs, project)
    return costs unless project
    settings = Setting.send "plugin_redmine_costs"
    cf = project.custom_field_values.select{|cfv| cfv.custom_field.name == settings['currency']}.first
    if cf
      value = cf.value
      return "#{costs} #{value}"
    end
    return costs
  end
end
