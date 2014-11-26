class AddIgnoreToRoster < ActiveRecord::Migration
  def change
    add_column :rosters, :ignore, :boolean, :default => false
  end
end
