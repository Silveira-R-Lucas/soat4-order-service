# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetOrCreateClientCart do
  let(:cart_repository) { instance_double('CartRepository') }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    let(:cart) { Cart.new(client_id: 1) }

    it 'busca ou cria pelo client_id se fornecido' do
      expect(cart_repository).to receive(:find_or_create_by_client_id).with(1, 1).and_return(cart)
      expect(subject.call(client_id: 1, cart_id: 1)).to eq(cart)
    end

    it 'cria carrinho anônimo se client_id não fornecido' do
      expect(cart_repository).to receive(:create_anonymous_cart).and_return(cart)
      expect(subject.call(client_id: nil, cart_id: nil)).to eq(cart)
    end
  end
end
