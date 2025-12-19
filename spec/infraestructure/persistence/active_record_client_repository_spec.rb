# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveRecordClientRepository do
  subject { described_class.new }

  # Limpa o banco para garantir testes isolados
  before { ClientModel.delete_all }

  describe '#save' do
    it 'cria um novo cliente no banco' do
      client = ClientModel.new(name: 'Teste', email: 'teste@email.com', cpf: '11111111111')
      saved_client = subject.save(client)

      expect(saved_client.id).not_to be_nil
      expect(ClientModel.count).to eq(1)
    end

    it 'atualiza um cliente existente' do
      existing = ClientModel.create!(name: 'Antigo', email: 'antigo@email.com', cpf: '22222222222')
      client = ClientModel.new(id: existing.id, name: 'Novo Nome', email: 'novo@email.com', cpf: '22222222222')

      subject.save(client)

      updated = ClientModel.find(existing.id)
      expect(updated.name).to eq('Novo Nome')
    end
  end

  describe '#find' do
    it 'retorna a entidade Client quando encontra' do
      model = ClientModel.create!(name: 'Busca', email: 'busca@email.com', cpf: '33333333333')
      result = subject.find(model.id)

      expect(result).to be_a(ClientModel)
      expect(result.id).to eq(model.id)
      expect(result.name).to eq('Busca')
    end

    it 'retorna nil se não encontrar' do
      expect(subject.find(999_999)).to be_nil
    end
  end

  describe '#find_by_email' do
    it 'encontra pelo email' do
      model = ClientModel.create!(name: 'Email', email: 'find@email.com', cpf: '44444444444')
      result = subject.find_by_email('find@email.com')
      expect(result.id).to eq(model.id)
    end

    it 'retorna nil se email não existir' do
      expect(subject.find_by_email('nada@email.com')).to be_nil
    end
  end

  describe '#find_by_cpf' do
    it 'encontra pelo cpf' do
      model = ClientModel.create!(name: 'CPF', email: 'cpf@email.com', cpf: '55555555555')
      result = subject.find_by_cpf('55555555555')
      expect(result.id).to eq(model.id)
    end

    it 'retorna nil se cpf não existir' do
      expect(subject.find_by_cpf('00000000000')).to be_nil
    end
  end
end
