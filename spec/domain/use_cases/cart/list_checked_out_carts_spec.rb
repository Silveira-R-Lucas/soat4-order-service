require 'rails_helper'

RSpec.describe ListCheckedOutCarts do
  let(:cart_repository) { instance_double("CartRepository") }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    it 'busca carrinhos com status finalizados' do
      expected_status = %w[ recebido em_preparação pronto finalizado]
      expect(cart_repository).to receive(:find_by_status).with(expected_status).and_return([])
      subject.call
    end
  end
end