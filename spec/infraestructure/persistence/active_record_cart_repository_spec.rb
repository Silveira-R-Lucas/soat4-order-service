require 'rails_helper'

RSpec.describe ActiveRecordCartRepository do
  subject { described_class.new }
  let!(:anonymous_client) do
    ClientModel.find_by(id: 99999) || 
    ClientModel.create!(id: 99999, name: 'Anônimo', email: 'anon@test.com', cpf: '00000000000')
  end
  let(:client) { ClientModel.create!(name: 'Lucas', email: 'lucas@test.com', cpf: '12345678900') }

  describe '#create_anonymous_cart' do
    it 'cria um carrinho sem cliente real associado' do
      cart = subject.create_anonymous_cart
      expect(cart).to be_a(Cart)
      expect(cart.client_id).to eq(99999) # Conforme implementação
      expect(CartModel.exists?(cart.id)).to be true
    end
  end

  describe '#find_or_create_by_client_id' do
    it 'cria um carrinho novo para o cliente se não existir' do
      cart = subject.find_or_create_by_client_id(client.id, nil)
      expect(cart.client_id).to eq(client.id)
    end

    it 'retorna carrinho existente' do
      existing = CartModel.create!(client_model: client, status: 'novo')
      cart = subject.find_or_create_by_client_id(client.id, existing.id)
      expect(cart.id).to eq(existing.id)
    end
  end

  describe '#save' do
    it 'salva o carrinho e seus itens' do
      # Setup
      product_model = ProductModel.create!(name: 'X-Bacon', category: 'Lanche', price: 20.0, quantity: 10, description: 'Bom')
      cart = subject.create_anonymous_cart
      
      # Adicionar item no domínio
      product = Product.new(id: product_model.id, name: 'X-Bacon', price: 20.0)
      cart.add_item(product: product, quantity: 2)
      cart.total_price = 40.0

      # Ação
      saved_cart = subject.save(cart)

      # Verificação
      persisted_cart = CartModel.find(saved_cart.id)
      expect(persisted_cart.total_price).to eq(40.0)
      expect(persisted_cart.cart_item_models.count).to eq(1)
      expect(persisted_cart.cart_item_models.first.quantity).to eq(2)
    end
  end
end