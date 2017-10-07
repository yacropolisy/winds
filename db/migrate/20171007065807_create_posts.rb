class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :hp
      t.string :title
      t.string :author
      t.timestamp :date
      t.text :article

      t.timestamps
    end
  end
end
