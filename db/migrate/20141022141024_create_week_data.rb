class CreateWeekData < ActiveRecord::Migration
  def change
    create_table :week_data do |t|
      t.integer :week, :null => false
      t.boolean :fan_duel, :default => false
      t.boolean :yahoo, :default => false
      t.boolean :dvoa, :default => false
      t.boolean :fftoday, :default => false

      t.timestamps
    end
  end
end
