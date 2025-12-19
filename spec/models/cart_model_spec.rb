# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartModel, type: :model do
  context 'associações' do
    it 'pertence a um cliente (opcional)' do
      association = described_class.reflect_on_association(:client_model)
      expect(association.macro).to eq :belongs_to
    end

    it 'tem muitos itens' do
      association = described_class.reflect_on_association(:cart_item_models)
      expect(association.macro).to eq :has_many
    end
  end
end
