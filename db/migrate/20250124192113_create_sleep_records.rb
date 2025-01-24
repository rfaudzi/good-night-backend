class CreateSleepRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sleep_records do |t|
      t.bigint :user_id, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: true
      t.integer :duration, null: true
      t.timestamps
    end

    add_index :sleep_records, [:user_id, :start_time, :duration]
    add_index :sleep_records, [:user_id, :duration]
  end
end
