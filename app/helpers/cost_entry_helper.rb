module CostEntryHelper
  def _cost_entries_path(project, issue, *args)
    if issue
      issue_cost_entries_path(issue, *args)
    elsif project
      project_cost_entries_path(project, *args)
    else
      cost_entries_path(*args)
    end
  end

  def _report_cost_entries_path(project, issue, *args)
    if issue
      report_issue_cost_entries_path(issue, *args)
    elsif project
      report_project_cost_entries_path(project, *args)
    else
      report_cost_entries_path(*args)
    end
  end

  def _new_cost_entry_path(project, issue, *args)
    if issue
      new_issue_cost_entry_path(issue, *args)
    elsif project
      new_project_cost_entry_path(project, *args)
    else
      new_cost_entry_path(*args)
    end
  end


  def format_criteria_value(criteria_options, value)
    if value.blank?
      "[#{l(:label_none)}]"
    elsif k = criteria_options[:klass]
      obj = k.find_by_id(value.to_i)
      if obj.is_a?(Issue)
        obj.visible? ? "#{obj.tracker} ##{obj.id}: #{obj.subject}" : "##{obj.id}"
      else
        obj
      end
    elsif cf = criteria_options[:custom_field]
      format_value(value, cf)
    else
      value.to_s
    end
  end

  def select_costs(data, criteria, value)
    if value.to_s.empty?
      data.select {|row| row[criteria].blank? }
    else
      data.select {|row| row[criteria].to_s == value.to_s}
    end
  end

  def sum_costs(data)
    sum = 0
    data.each do |row|
      sum += row['costs'].to_f
    end
    sum
  end
end
