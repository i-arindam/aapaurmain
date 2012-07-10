class AddNotificationDatesToUser < ActiveRecord::Migration
  def change
    add_column :users, :notifying_for_success_date, :date
    add_column :users, :marriage_informed_date, :date
    add_column :users, :rejected_on, :date
  end
end
