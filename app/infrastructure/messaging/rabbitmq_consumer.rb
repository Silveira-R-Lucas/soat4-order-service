# frozen_string_literal: true

class RabbitmqConsumer
  require 'json'

  def initialize(exchange_name, queue_name, handlers = {})
    @channel = RabbitmqConnection.channel
    @exchange = @channel.fanout(exchange_name, durable: true)
    @queue = @channel.queue(queue_name, durable: true)
    @queue.bind(@exchange)
    @handlers = handlers
  end

  def start_listening
    Rails.logger.info("🎧 Listening to #{@queue.name}")
    @queue.subscribe(block: true, manual_ack: true) do |delivery_info, _properties, payload|
      handle_message(payload)
      @channel.ack(delivery_info.delivery_tag)
    end
  rescue Interrupt
    @channel.close
    RabbitmqConnection.instance.close
  end

  private

  def handle_message(payload)
    data = JSON.parse(payload)
    event = data['event']
    payload_data = data['payload']
    @handlers[event]
    cart_repository = ActiveRecordCartRepository.new
    puts "Atualizando o pedido #{payload_data['pedido_id']}"
    puts "payload_data: #{payload_data}"

    case event
    when 'PagamentoCriado'
      puts "✅ [OrderService] Pagamento criado para pedido #{payload_data['pedido_id']}"
      UpdateCartPaymentStatus.new(cart_repository: cart_repository).call(cart_id: payload_data['pedido_id'],
                                                                         payment_status: 'criado', payment_details: payload_data['payment_details'])
    when 'PagamentoAprovado'
      puts "✅ [OrderService] Pagamento aprovado para pedido #{payload_data['pedido_id']}"
      UpdateCartPaymentStatus.new(cart_repository: cart_repository).call(cart_id: payload_data['pedido_id'],
                                                                         payment_status: 'pago')
    when 'PagamentoRecusado'
      puts "❌ [OrderService] Pagamento recusado para pedido #{payload_data['pedido_id']}"
      UpdateCartPaymentStatus.new(cart_repository: cart_repository).call(cart_id: payload_data['pedido_id'],
                                                                         payment_status: 'falha_pagamento')
    else
      Rails.logger.warn("⚠️ No handler for event: #{event}")
    end
  rescue StandardError => e
    Rails.logger.error("❌ Error handling message: #{e.message}")
  end
end
