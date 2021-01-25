class CreateRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :recipients do |t|
      t.string :name
      t.string :email
      t.string :address
      t.references :school, index: true, foreign_key: true

      t.timestamps
    end
  end
end
