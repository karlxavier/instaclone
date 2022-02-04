class CreateFriendships < ActiveRecord::Migration[6.1]
  def change
    create_table :friendships do |t|
      t.references :user
      t.integer :friend_id
      t.string :status
      t.datetime :requested_at
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
