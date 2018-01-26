class CreateBasketComplements < ActiveRecord::Migration[5.2]
  def change
    create_table :basket_complements do |t|
      t.string :name, null: false
      t.decimal :price, scale: 3, precision: 8, default: 0, null: false
    end

    create_table :basket_complements_deliveries do |t|
      t.references :basket_complement, null: false, index: false
      t.references :delivery, null: false, index: false
    end
    add_index :basket_complements_deliveries, [:basket_complement_id, :delivery_id], unique: true, name: 'basket_complements_deliveries_unique_index'

    create_table :basket_complements_memberships do |t|
      t.references :basket_complement, null: false, index: false
      t.references :membership, null: false, index: false
    end
    add_index :basket_complements_memberships, [:basket_complement_id, :membership_id], unique: true, name: 'basket_complements_memberships_unique_index'

    create_table :basket_complements_baskets do |t|
      t.references :basket_complement, null: false, index: false
      t.references :basket, null: false, index: false
    end
    add_index :basket_complements_baskets, [:basket_complement_id, :basket_id], unique: true, name: 'basket_complements_baskets_unique_index'

    add_column :baskets, :complement_prices, :jsonb, default: {}, null: false
  end
end
