class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :league

      t.timestamps
    end
  end
end
