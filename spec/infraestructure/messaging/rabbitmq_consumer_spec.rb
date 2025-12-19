# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RabbitmqConsumer do
  # Mock do Canal e Fila do Bunny
  let(:channel) { double('Channel', fanout: double, queue: double(bind: true, subscribe: true), ack: true) }

  # Mock do Repositório e Use Case
  let(:cart_repo) { instance_double(ActiveRecordCartRepository) }
  let(:update_payment_service) { instance_double(UpdateCartPaymentStatus) }

  before do
    allow(RabbitmqConnection).to receive(:channel).and_return(channel)
    allow(ActiveRecordCartRepository).to receive(:new).and_return(cart_repo)
    allow(UpdateCartPaymentStatus).to receive(:new).with(cart_repository: cart_repo).and_return(update_payment_service)
  end

  describe '#handle_message (privado, acessado via send)' do
    let(:consumer) { described_class.new('exchange', 'queue') }

    context 'Evento: PagamentoCriado' do
      let(:payload) do
        {
          event: 'PagamentoCriado',
          payload: { 'pedido_id' => 123, 'payment_details' => 'qr_code' }
        }.to_json
      end

      it 'chama UpdateCartPaymentStatus com status criado' do
        expect(update_payment_service).to receive(:call).with(
          cart_id: 123,
          payment_status: 'criado',
          payment_details: 'qr_code'
        )

        consumer.send(:handle_message, payload)
      end
    end

    context 'Evento: PagamentoAprovado' do
      let(:payload) do
        {
          event: 'PagamentoAprovado',
          payload: { 'pedido_id' => 456 }
        }.to_json
      end

      it 'chama UpdateCartPaymentStatus com status pago' do
        expect(update_payment_service).to receive(:call).with(
          cart_id: 456,
          payment_status: 'pago'
        )

        consumer.send(:handle_message, payload)
      end
    end

    context 'Evento: PagamentoRecusado' do
      let(:payload) do
        {
          event: 'PagamentoRecusado',
          payload: { 'pedido_id' => 789 }
        }.to_json
      end

      it 'chama UpdateCartPaymentStatus com status falha_pagamento' do
        expect(update_payment_service).to receive(:call).with(
          cart_id: 789,
          payment_status: 'falha_pagamento'
        )

        consumer.send(:handle_message, payload)
      end
    end

    context 'Tratamento de Erros' do
      let(:payload) { { event: 'EventoQuebrado', payload: {} }.to_json }

      it 'captura exceções e loga o erro sem quebrar a aplicação' do
        # Força um erro no JSON.parse ou qualquer lógica interna
        allow(JSON).to receive(:parse).and_raise(StandardError.new('JSON Inválido'))

        expect(Rails.logger).to receive(:error).with(/Error handling message: JSON Inválido/)

        expect do
          consumer.send(:handle_message, payload)
        end.not_to raise_error
      end
    end

    context 'Evento Desconhecido' do
      let(:payload) { { event: 'EventoInexistente', payload: {} }.to_json }

      it 'loga aviso sobre handler não encontrado' do
        expect(Rails.logger).to receive(:warn).with(/No handler for event: EventoInexistente/)
        consumer.send(:handle_message, payload)
      end
    end
  end
end
