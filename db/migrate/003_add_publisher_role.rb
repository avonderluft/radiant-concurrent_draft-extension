class AddPublisherRole < ActiveRecord::Migration
  def self.up
    add_column :users, :publisher, :boolean, :default => false
  end
  
  def self.down
    remove_column :users, :publisher
  end
end