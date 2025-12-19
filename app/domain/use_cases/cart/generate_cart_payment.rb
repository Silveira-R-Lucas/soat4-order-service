# frozen_string_literal: true

class GenerateCartPayment
  def initialize(cart_repository:, payment_gateway_adapter:)
    @cart_repository = cart_repository
    @payment_gateway_adapter = payment_gateway_adapter
  end

  def call(cart:)
    raise ArgumentError, 'Erro ao gerar pagamento, carrinho vazio.' if cart.items.empty?

    unless cart.payment_status == 'pendente'
      raise ArgumentError,
            "Pagamento já foi gerado para este pedido (status: #{cart.payment_status})."
    end

    payment_result = @payment_gateway_adapter.generate_qr_payment(cart)
    raise ArgumentError, "Payment gateway failed: #{payment_result[:error]}" unless payment_result[:successful]

    cart.update_payment_status!('aguardando_pagamento')
    @cart_repository.save(cart)
    {
      successful: true,
      cart: cart,
      payment_details: {
        payment_id: payment_result[:response]['in_store_order_id'],
        qr_data: payment_result[:response]['qr_data']
      }
    }
  rescue ArgumentError => e
    raise e
  end
end
