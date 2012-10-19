class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|

      t.timestamps
    end
  end
end
