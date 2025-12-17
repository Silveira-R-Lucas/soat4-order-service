require 'rails_helper'

RSpec.describe CheckoutCart do
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
    let(:cart) { Cart.new(status: 'novo', payment_status: 'aprovado', items: [cart_item]) }

    it 'marca o carrinho como recebido e salva' do
      expect(cart_repository).to receive(:save).with(cart)
      
      result = subject.call(cart: cart)
      
      expect(result.status).to eq('recebido')
    end

    it 'lança erro se o carrinho estiver vazio' do
      empty_cart = Cart.new(items: [])
      expect { subject.call(cart: empty_cart) }.to raise_error(ArgumentError, /Carrinho vazio/)
    end
    
    it 'lança erro se pagamento não estiver aprovado' do
      unpaid_cart = Cart.new(payment_status: 'pendente', items: [cart_item])
      expect { subject.call(cart: unpaid_cart) }.to raise_error(ArgumentError, /Pagamento pendente/)
    end
  end
end