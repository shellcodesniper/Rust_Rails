class AddManagersToServers < ActiveRecord::Migration[5.2]
  def change
    add_column :servers, :world_reset_type, :string
    add_column :servers, :map_reset_type, :string
    add_column :servers, :start_date, :datetime
    add_column :servers, :world_reset_count, :integer
    add_column :servers, :map_reset_count, :integer
    add_column :servers, :world_reset_command, :text
    add_column :servers, :map_reset_command, :text
    add_column :servers, :world_reset_notice_message, :text
    add_column :servers, :map_reset_notice_message, :text
  end
end
