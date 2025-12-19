# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateProduct do
  let(:product_repository) { instance_double('ProductRepository') }
  subject { described_class.new(product_repository: product_repository) }

  describe '#call' do
    let(:product) { Product.new(id: 1, name: 'Old Name', price: 10.0) }

    before do
      allow(product_repository).to receive(:find).with(1).and_return(product)
    end

    it 'atualiza os atributos do produto e salva' do
      expect(product_repository).to receive(:save).with(product)

      updated = subject.call(id: 1, attributes: { name: 'New Name', price: 15.0 })

      expect(updated.name).to eq('New Name')
      expect(updated.price).to eq(15.0)
    end

    it 'retorna nil se o produto não existir' do
      allow(product_repository).to receive(:find).with(999).and_return(nil)
      expect(subject.call(id: 999, attributes: {})).to be_nil
    end
  end
end
