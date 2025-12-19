# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateCartPayment do
  let(:cart_repository) { instance_double('CartRepository') }
  let(:gateway) { instance_double('PaymentGatewayAdapter') }
  subject { described_class.new(cart_repository: cart_repository, payment_gateway_adapter: gateway) }

  describe '#call' do
    let(:product) { build(:product) }
    let(:cart_item) do
      build(:cart_item,
            product_id: product.id,
            product_name: product.name,
            product_price: product.price,
            quantity: 2)
    end
    let(:cart) { Cart.new(id: 1, items: [cart_item], payment_status: 'pendente') }
    let(:success_response) do
      { successful: true, response: { 'in_store_order_id' => '123', 'qr_data' => 'qr123' } }
    end

    it 'gera pagamento e atualiza status para aguardando_pagamento' do
      expect(gateway).to receive(:generate_qr_payment).with(cart).and_return(success_response)
      expect(cart_repository).to receive(:save).with(cart)

      result = subject.call(cart: cart)

      expect(result[:successful]).to be true
      expect(cart.payment_status).to eq('aguardando_pagamento')
      expect(result[:payment_details][:qr_data]).to eq('qr123')
    end

    it 'lança erro se carrinho estiver vazio' do
      empty_cart = Cart.new(items: [])
      expect { subject.call(cart: empty_cart) }.to raise_error(ArgumentError, /carrinho vazio/)
    end

    it 'lança erro se pagamento não for pendente' do
      paid_cart = Cart.new(items: [cart_item], payment_status: 'aprovado')
      expect { subject.call(cart: paid_cart) }.to raise_error(ArgumentError, /já foi gerado/)
    end
  end
end
