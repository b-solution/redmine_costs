class CreateCostEntries < ActiveRecord::Migration
  def change
    create_table :cost_entries do |t|
      t.integer :project_id
      t.integer :issue_id
      t.integer :user_id
      t.integer :activity_id
      t.float   :costs
      t.string  :comments
      t.integer :tyear
      t.integer :tmonth
      t.integer :tweek
      t.date :spent_on

      t.timestamps
    end
  end
end
