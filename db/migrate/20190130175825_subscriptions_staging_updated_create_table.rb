class SubscriptionsStagingUpdatedCreateTable < ActiveRecord::Migration[5.2]
  def up
    create_table :staging_subscriptions_updated do |t|
      t.string :subscription_id
      t.string :address_id
      t.string :customer_id
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :next_charge_scheduled_at
      t.datetime :cancelled_at
      t.string :product_title
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity
      t.string :status
      t.string :shopify_product_id
      t.string :shopify_variant_id
      t.string :sku
      t.string :order_interval_unit
      t.integer :order_interval_frequency
      t.integer :charge_interval_frequency
      t.integer :order_day_of_month
      t.integer :order_day_of_week
      t.jsonb :raw_line_item_properties
      t.datetime :synced_at
      t.integer :expire_after_specific_number_charges
      t.boolean :updated, default: false
      t.datetime :updated_at

    end
  end

  def down
    drop_table :staging_subscriptions_updated
  end
end
