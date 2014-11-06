class CreateDvoas < ActiveRecord::Migration
  def change
    create_table :dvoas do |t|
      t.string :team
      t.references :import, index: true
      t.string :role
      t.string :subrole
      t.decimal :value

      t.timestamps
    end
  end
end
