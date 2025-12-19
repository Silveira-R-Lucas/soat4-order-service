# frozen_string_literal: true

class CreateCartModels < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_models do |t|
      t.decimal :total_price, precision: 17, scale: 2
      t.references :client_model, foreign_key: true
      t.string :status, default: 'novo', null: false
      t.string :payment_status, default: 'pendente', null: false
      t.timestamps
    end
  end
end
