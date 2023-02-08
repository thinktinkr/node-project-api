class CreateBirds < ActiveRecord::Migration[7.0]
  def change
    create_table :birds do |t|
      t.integer :node_id
    end
    add_index :birds, :id
    add_index :birds, :node_id
  end
end
