require 'rails_helper'

RSpec.describe CreateProduct do
  let(:product_repository) { instance_double("ProductRepository") }
  subject { described_class.new(product_repository: product_repository) }

  describe '#call' do
    let(:params) { { name: 'X-Burger', price: 20.0 } }
    let(:product) { Product.new(params) }

    it 'cria e salva um novo produto' do
      expect(product_repository).to receive(:save).with(an_instance_of(Product))
      
      result = subject.call(params)
      
      expect(result).to be_a(Product)
      expect(result.name).to eq('X-Burger')
    end
  end
end