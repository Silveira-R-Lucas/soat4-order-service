# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindProductsByCategory do
  let(:product_repository) { instance_double('ProductRepository') }
  subject { described_class.new(product_repository: product_repository) }

  describe '#call' do
    let(:products) { [Product.new(category: 'Lanches'), Product.new(category: 'Lanches')] }

    it 'retorna lista de produtos da categoria' do
      allow(product_repository).to receive(:find_by_category).with('Lanches').and_return(products)
      result = subject.call(category_name: 'Lanches')
      expect(result.size).to eq(2)
    end
  end
end
