class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :school, index: true, foreign_key: true
      t.string :status
      t.string :gifts, array: true, default: [] 
      t.boolean :send_email, default: false
      t.timestamps
    end

    # add_column :orders, :gifts, :string, array: true, default: []

    create_table :orders_recipients, :id => false do |t|
      t.integer :order_id
      t.integer :recipient_id
    end 
  end
end
