class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.string :type, :null => false
      t.string :subtype, :null => false
      t.integer :week, :null => false
      t.integer :status, :null => false, :default => 0
      t.string :url, :null => false

      t.timestamps
    end
  end
end
