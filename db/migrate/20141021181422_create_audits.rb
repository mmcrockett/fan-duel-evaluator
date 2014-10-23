class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.string :source, :null => false
      t.string :subsource, :null => false
      t.integer :week, :null => false
      t.integer :status, :null => false, :default => 0
      t.string :url, :null => false

      t.timestamps
    end
  end
end
