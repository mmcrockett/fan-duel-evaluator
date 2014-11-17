class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.references :import, index: true
      t.string :notes
      t.string :player_ids

      t.timestamps
    end
  end
end
