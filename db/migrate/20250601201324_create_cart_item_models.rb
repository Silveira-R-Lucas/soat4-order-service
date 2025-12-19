# frozen_string_literal: true

class CreateCartItemModels < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_item_models do |t|
      t.references :cart_model, null: false, foreign_key: true
      t.references :product_model, null: false, foreign_key: true
      t.integer :quantity, :integer, default: 1
      t.string :descricao
      t.timestamps
    end
  end
end
