require 'rails_helper'

RSpec.describe CartItem do
  subject do
    described_class.new(
      id: 1,
      cart_id: 10,
      product_id: 5,
      product_name: 'Batata',
      product_price: 10.0,
      quantity: 2
    )
  end

  describe '#total' do
    it 'calcula o preço total' do
      expect(subject.total).to eq(20.0)
    end
  end

  describe '#to_h' do
    it 'retorna hash com atributos corretos' do
      hash = subject.to_h
      expect(hash[:product_name]).to eq('Batata')
      expect(hash[:total]).to eq(20.0)
    end
  end
end