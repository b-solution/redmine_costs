class AddTimeEntryToCostEntry < ActiveRecord::Migration
  def change
    add_column :cost_entries, :time_entry_id, :integer
  end
end
