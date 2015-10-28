class CostEntryActivity < Enumeration
  has_many :cost_entries, :foreign_key => 'activity_id'

  OptionName = :enumeration_activities_cost

  def option_name
    OptionName
  end

  def objects
    CostEntry.where(:activity_id => self_and_descendants(1).map(&:id))
  end

  def objects_count
    objects.count
  end

  def transfer_relations(to)
    objects.update_all(:activity_id => to.id)
  end
end