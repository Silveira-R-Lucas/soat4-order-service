require 'rails_helper'

RSpec.describe ActiveRecordProductRepository do
  subject { described_class.new }

  # FactoryBot deve estar configurado para criar ProductModel
  let!(:product_model) { ProductModel.create!(name: 'Coca', category: 'Bebida', price: 5.0, quantity: 100, description: 'Gelada') }

  describe '#find' do
    it 'retorna uma entidade Product de domínio' do
      result = subject.find(product_model.id)
      
      expect(result).to be_a(Product)
      expect(result.id).to eq(product_model.id)
      expect(result.name).to eq('Coca')
    end

    it 'retorna nil se não encontrar' do
      expect(subject.find(9999)).to be_nil
    end
  end

  describe '#save' do
    it 'cria um novo registro se não tiver ID' do
      new_product = Product.new(name: 'Fanta', category: 'Bebida', price: 5.0, quantity: 50, description: 'Laranja')
      
      saved_product = subject.save(new_product)
      
      expect(saved_product.id).not_to be_nil
      expect(ProductModel.count).to eq(2)
    end

    it 'atualiza registro existente se tiver ID' do
      domain_product = subject.find(product_model.id)
      domain_product.price = 6.0
      
      subject.save(domain_product)
      
      expect(ProductModel.find(product_model.id).price).to eq(6.0)
    end
  end

  describe '#delete' do
    it 'remove o registro do banco' do
      result = subject.delete(product_model.id)
      expect(result).to be true
      expect(ProductModel.exists?(product_model.id)).to be false
    end
  end
end