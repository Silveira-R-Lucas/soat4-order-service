require 'rails_helper'

RSpec.describe FindProductById do
  let(:product_repository) { instance_double("ProductRepository") }
  subject { described_class.new(product_repository: product_repository) }

  describe '#call' do
    let(:product) { Product.new(id: 1, name: 'Burger') }

    it 'retorna o produto quando encontrado' do
      allow(product_repository).to receive(:find).with(1).and_return(product)
      expect(subject.call(id: 1)).to eq(product)
    end

    it 'retorna nil quando não encontrado' do
      allow(product_repository).to receive(:find).with(999).and_return(nil)
      expect(subject.call(id: 999)).to be_nil
    end
  end
end