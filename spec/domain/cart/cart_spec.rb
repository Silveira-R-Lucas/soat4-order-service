# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart do
  let(:product) { Product.new(id: 1, name: 'Burger', price: 10.0) }
  let(:cart) { described_class.new(id: 1, client_id: 1) }

  describe '#add_item' do
    it 'adiciona um novo item se não existir' do
      cart.add_item(product: product, quantity: 2)
      expect(cart.items.size).to eq(1)
      expect(cart.items.first.quantity).to eq(2)
    end

    it 'incrementa a quantidade se o item já existir' do
      cart.add_item(product: product, quantity: 1)
      cart.add_item(product: product, quantity: 3)
      expect(cart.items.size).to eq(1)
      expect(cart.items.first.quantity).to eq(4)
    end
  end

  describe '#remove_item' do
    before { cart.add_item(product: product, quantity: 5) }

    it 'remove parcialmente a quantidade' do
      cart.remove_item(product_id: 1, quantity: 2)
      expect(cart.items.first.quantity).to eq(3)
    end

    it 'remove o item completamente se a quantidade for igual ou maior' do
      cart.remove_item(product_id: 1, quantity: 5)
      expect(cart.items).to be_empty
    end

    it 'remove o item completamente se quantidade for nil' do
      cart.remove_item(product_id: 1)
      expect(cart.items).to be_empty
    end

    it 'retorna false se o item não existir' do
      expect(cart.remove_item(product_id: 999)).to be false
    end
  end

  describe '#update_item_quantity' do
    before { cart.add_item(product: product, quantity: 1) }

    it 'atualiza a quantidade direta' do
      cart.update_item_quantity(product_id: 1, new_quantity: 10)
      expect(cart.items.first.quantity).to eq(10)
    end

    it 'remove o item se a nova quantidade for 0' do
      cart.update_item_quantity(product_id: 1, new_quantity: 0)
      expect(cart.items).to be_empty
    end

    it 'retorna false se item não existir' do
      expect(cart.update_item_quantity(product_id: 999, new_quantity: 5)).to be false
    end
  end

  describe '#total_amount' do
    it 'calcula a soma total dos itens' do
      p1 = Product.new(id: 1, price: 10.0)
      p2 = Product.new(id: 2, price: 5.50)

      cart.add_item(product: p1, quantity: 2) # 20.0
      cart.add_item(product: p2, quantity: 1) # 5.5

      expect(cart.total_amount).to eq(25.5)
    end
  end

  describe '#update_status!' do
    it 'atualiza para um status válido' do
      cart.update_status!('em_preparação')
      expect(cart.status).to eq('em_preparação')
    end

    it 'lança erro para status inválido' do
      expect { cart.update_status!('invalido') }
        .to raise_error(ArgumentError, /Status inválido/)
    end

    it 'lança erro se tentar mudar status de finalizado' do
      cart.status = 'finalizado'
      expect { cart.update_status!('novo') }
        .to raise_error(ArgumentError, /Não é possível mudar pedido 'finalizado'/)
    end
  end

  describe '#mark_as_received!' do
    it 'muda status para recebido se pagamento aprovado' do
      cart.add_item(product: product)
      cart.payment_status = 'aprovado'
      cart.mark_as_received!
      expect(cart.status).to eq('recebido')
    end

    it 'lança erro se carrinho vazio' do
      cart.payment_status = 'aprovado'
      expect { cart.mark_as_received! }
        .to raise_error(ArgumentError, /Carrinho vazio/)
    end

    it 'lança erro se pagamento pendente' do
      cart.add_item(product: product)
      cart.payment_status = 'pendente'
      expect { cart.mark_as_received! }
        .to raise_error(ArgumentError, /Pagamento pendente/)
    end
  end
end
