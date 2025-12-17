require 'rails_helper'

RSpec.describe AddProductToCart do
  let(:cart_repo) { instance_double(ActiveRecordCartRepository) }
  let(:product_repo) { instance_double(ActiveRecordProductRepository) }
  
  # System Under Test
  subject { described_class.new(cart_repository: cart_repo, product_repository: product_repo) }

  describe '#call' do
    let(:client_id) { 1 }
    let(:product) { Product.new(id: 1, name: 'Burger', price: 10.0, quantity: 5) }
    let(:cart) { Cart.new(client_id: client_id) }

    context 'quando o produto existe e a quantidade é válida' do
      before do
        allow(product_repo).to receive(:find).with(1).and_return(product)
        allow(cart_repo).to receive(:save).and_return(cart)
      end

      it 'adiciona o item ao carrinho' do
        updated_cart = subject.call(client_id: client_id, product_id: 1, quantity: 2, cart: cart)
        
        expect(updated_cart.items.first.product_id).to eq(1)
        expect(updated_cart.items.first.quantity).to eq(2)
        expect(updated_cart.items.first.total).to eq(20.0) # 2 * 10.0
      end
    end

    context 'quando a quantidade é inválida' do
      it 'lança um erro' do
        expect {
          subject.call(client_id: client_id, product_id: 1, quantity: 0, cart: cart)
        }.to raise_error(ArgumentError, /Quantidade precisa ser maior que 0/)
      end
    end
  end
end