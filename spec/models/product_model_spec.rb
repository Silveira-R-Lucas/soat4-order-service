require 'rails_helper'

RSpec.describe ProductModel, type: :model do
  subject { 
    described_class.new(
      name: 'Test Product', 
      category: 'Lanche', 
      price: 10.0, 
      quantity: 10, 
      description: 'Desc'
    ) 
  }

  context 'validations' do
    it 'é válido com atributos válidos' do
      expect(subject).to be_valid
    end

    it 'requer name' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it 'requer category' do
      subject.category = nil
      expect(subject).to_not be_valid
    end

    it 'requer price' do
      subject.price = nil
      expect(subject).to_not be_valid
    end

    it 'price deve ser maior ou igual a 0' do
      subject.price = -1
      expect(subject).to_not be_valid
    end
  end
end