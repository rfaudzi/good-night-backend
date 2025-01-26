class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      t.bigint :follower_id, null: false
      t.bigint :following_id, null: false
      t.datetime :deleted_at, null: true
      t.timestamps
    end

    add_index :follows, [:follower_id, :following_id, :deleted_at]
    add_index :follows, [:following_id, :deleted_at]
  end
end

