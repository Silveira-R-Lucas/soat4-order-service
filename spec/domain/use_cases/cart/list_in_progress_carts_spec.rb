# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListInProgressCarts do
  let(:cart_repository) { instance_double('CartRepository') }
  subject { described_class.new(cart_repository: cart_repository) }

  describe '#call' do
    it 'busca carrinhos em progresso (pronto, preparacao, recebido)' do
      expected_status = %w[pronto em_preparação recebido]
      expect(cart_repository).to receive(:find_by_status).with(expected_status).and_return([])
      subject.call
    end
  end
end
