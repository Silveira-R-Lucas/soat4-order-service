require 'rails_helper'

RSpec.describe UpdateCartPaymentStatus do
  let(:cart_repository) { instance_double("CartRepository") }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    let(:product) { build(:product) } 
    let(:cart_item) do 
        build(:cart_item, 
        product_id: product.id, 
        product_name: product.name, 
        product_price: product.price,
        quantity: 2
        ) 
    end
    let(:cart) { Cart.new(id: 1, payment_status: 'pendente', items: [cart_item]) }

    before do
      allow(cart_repository).to receive(:find).with(1).and_return(cart)
    end

    it 'marca como pago e recebido se status for pago' do
      expect(cart_repository).to receive(:save).with(cart) # save do mark_as_received
      
      updated_cart = subject.call(cart_id: 1, payment_status: 'pago')
      
      expect(updated_cart.payment_status).to eq('aprovado')
      expect(updated_cart.status).to eq('recebido')
    end

    it 'apenas atualiza o status de pagamento para outros status' do
      expect(cart_repository).to receive(:save).with(cart)
      
      updated_cart = subject.call(cart_id: 1, payment_status: 'rejeitado')
      
      expect(updated_cart.payment_status).to eq('rejeitado')
      expect(updated_cart.status).to eq('novo') # não mudou para recebido
    end

    it 'lança erro se carrinho não encontrado' do
      allow(cart_repository).to receive(:find).with(999).and_return(nil)
      expect {
        subject.call(cart_id: 999, payment_status: 'pago')
      }.to raise_error(ArgumentError, /Cart with ID 999 not found/)
    end
  end
end