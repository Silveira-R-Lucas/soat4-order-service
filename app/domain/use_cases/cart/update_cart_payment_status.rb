class UpdateCartPaymentStatus
  def initialize(cart_repository:)
    @cart_repository = cart_repository
  end

  def call(cart_id:, payment_status:, payment_details: nil)
    cart = @cart_repository.find(cart_id)
    raise ArgumentError, "Cart with ID #{cart_id} not found." unless cart

    if payment_status == 'pago'
        cart.mark_as_paid
        cart.mark_as_received!
        @cart_repository.save(cart)
    else
        cart.update_payment_status!(payment_status)
    end
    cart.update_payment_details!(payment_details) if payment_details
    @cart_repository.save(cart)

    cart
  rescue ArgumentError => e
    raise e
  end
end
