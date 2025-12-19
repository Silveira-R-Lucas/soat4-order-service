# frozen_string_literal: true

class CreateClientModels < ActiveRecord::Migration[7.0]
  def change
    create_table :client_models do |t|
      t.string :name
      t.string :email
      t.string :cpf
      t.timestamps
    end

    add_index :client_models, :cpf, unique: true
  end
end
