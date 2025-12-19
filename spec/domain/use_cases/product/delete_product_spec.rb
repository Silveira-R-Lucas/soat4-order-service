# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteProduct do
  let(:product_repository) { instance_double('ProductRepository') }
  subject { described_class.new(product_repository: product_repository) }

  describe '#call' do
    it 'deleta o produto pelo ID' do
      expect(product_repository).to receive(:delete).with(1).and_return(true)
      expect(subject.call(id: 1)).to be_truthy
    end
  end
end
