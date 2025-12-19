# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateProductQuantityInCart do
  let(:cart_repository) { instance_double('CartRepository') }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    let(:product) { build(:product) }
    let(:cart_item) do
      build(:cart_item,
            product_id: product.id,
            product_name: product.name,
            product_price: product.price,
            quantity: 2)
    end
    let(:cart) { Cart.new(items: [cart_item]) }

    it 'atualiza a quantidade do item' do
      expect(cart_repository).to receive(:save).with(cart)

      subject.call(client_id: 1, product_id: product.id, new_quantity: 5, cart: cart)

      expect(cart_item.quantity).to eq(5)
    end

    it 'lança erro se quantidade for negativa' do
      expect do
        subject.call(client_id: 1, product_id: product.id, new_quantity: -1, cart: cart)
      end.to raise_error(ArgumentError, /não negativo/)
    end

    it 'lança erro se produto não estiver no carrinho' do
      expect do
        subject.call(client_id: 1, product_id: 999, new_quantity: 5, cart: cart)
      end.to raise_error(ArgumentError, /não encontrado no carrinho/)
    end
  end
end
