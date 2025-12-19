# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientModel, type: :model do
  subject { described_class.new(name: 'John', email: 'john@doe.com', cpf: '12345678900') }

  context 'validations' do
    it 'é válido com atributos válidos' do
      expect(subject).to be_valid
    end

    it 'requer name' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it 'requer email' do
      subject.email = nil
      expect(subject).to_not be_valid
    end

    it 'requer cpf' do
      subject.cpf = nil
      expect(subject).to_not be_valid
    end
  end
end
