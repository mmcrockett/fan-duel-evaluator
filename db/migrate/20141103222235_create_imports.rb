class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :league, :null => false
      t.integer :fd_contest_id, :null => false
      t.string  :fd_team_data, :null => false
      t.boolean :ignore, :null => false, :default => false

      t.timestamps
    end
  end
end
