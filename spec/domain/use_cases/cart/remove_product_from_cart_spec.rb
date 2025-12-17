require 'rails_helper'

RSpec.describe RemoveProductFromCart do
  let(:cart_repository) { instance_double("CartRepository") }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    let(:product) { build(:product) } 
    let(:cart_item) do 
        build(:cart_item, 
        product_id: product.id, 
        product_name: product.name, 
        product_price: product.price,
        quantity: 5
        ) 
    end
    let(:cart) { Cart.new(items: [cart_item]) }

    it 'remove quantidade parcial do item' do
      expect(cart_repository).to receive(:save).with(cart)
      
      subject.call(client_id: 1, product_id: product.id, quantity: 2, cart: cart)
      
      expect(cart_item.quantity).to eq(3)
    end

    it 'remove o item totalmente se quantidade não informada' do
      expect(cart_repository).to receive(:save).with(cart)
      
      subject.call(client_id: 1, product_id: product.id, quantity: nil, cart: cart)
      
      expect(cart.items).to be_empty
    end

    it 'lança erro se produto não estiver no carrinho' do
      expect {
        subject.call(client_id: 1, product_id: 999, quantity: 1, cart: cart)
      }.to raise_error(ArgumentError, /não encontrado no carrinho/)
    end
  end
end