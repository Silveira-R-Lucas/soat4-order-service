# frozen_string_literal: true

class UpdateCartStatus
  def initialize(cart_repository:)
    @cart_repository = cart_repository
  end

  def call(cart_id:, new_status:, payment_details: nil)
    cart = @cart_repository.find(cart_id)
    raise ArgumentError, "Cart with ID #{cart_id} not found." unless cart

    cart.update_status!(new_status) unless new_status == 'pago'
    cart.update_payment_details!(payment_details) if payment_details
    @cart_repository.save(cart)

    cart
  rescue ArgumentError => e
    raise e
  end
end
