class CreateFfTodayPredictions < ActiveRecord::Migration
  def change
    create_table :ff_today_predictions do |t|
      t.string :position, :null => false
      t.integer :week, :null => false
      t.string :team, :null => false
      t.string :opponent, :null => false
      t.decimal :value, :null => false, :precision => 4, :scale => 2

      t.timestamps
    end
  end
end
