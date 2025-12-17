require 'rails_helper'

RSpec.describe Product do
  describe '#available?' do
    it 'é verdadeiro quando quantidade > 0' do
      product = Product.new(quantity: 1)
      expect(product.available?).to be true
    end

    it 'é falso quando quantidade é 0' do
      product = Product.new(quantity: 0)
      expect(product.available?).to be false
    end
  end
end