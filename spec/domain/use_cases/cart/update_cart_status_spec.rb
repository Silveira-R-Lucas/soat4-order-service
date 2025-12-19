# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateCartStatus do
  let(:cart_repository) { instance_double('CartRepository') }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    let(:cart) { Cart.new(id: 1, status: 'recebido') }

    before do
      allow(cart_repository).to receive(:find).with(1).and_return(cart)
    end

    it 'atualiza o status para em_preparação' do
      expect(cart_repository).to receive(:save).with(cart)

      subject.call(cart_id: 1, new_status: 'em_preparação')

      expect(cart.status).to eq('em_preparação')
    end

    it 'ignora status "pago" (tratado em outro lugar ou não faz nada)' do
      # Pela lógica do arquivo, if new_status == 'pago' else update
      # se for 'pago', ele pula o update_status! mas salva e retorna
      expect(cart_repository).to receive(:save).with(cart)

      subject.call(cart_id: 1, new_status: 'pago')
      expect(cart.status).to eq('recebido') # inalterado
    end

    it 'lança erro para status inválido (regra da entidade Cart)' do
      # Assumindo que Cart#update_status! valida status
      expect do
        subject.call(cart_id: 1, new_status: 'status_maluco')
      end.to raise_error(ArgumentError, /Status inválido/)
    end
  end
end
