# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RabbitmqConnection do
  let(:bunny_session) { instance_double(Bunny::Session) }
  let(:channel) { instance_double(Bunny::Channel) }

  before do
    allow(Bunny).to receive(:new).and_return(bunny_session)
    allow(bunny_session).to receive(:start)
    allow(bunny_session).to receive(:create_channel).and_return(channel)
    # Silencia o puts e sleep para não sujar o log de teste
    allow(described_class).to receive(:puts)
    allow(described_class).to receive(:sleep)
  end

  describe '.start' do
    it 'inicia a conexão com sucesso' do
      expect(described_class.start).to eq(bunny_session)
    end

    it 'tenta reconectar em caso de falha de rede' do
      # Simula falha na primeira vez, e sucesso na segunda
      call_count = 0
      allow(bunny_session).to receive(:start) do
        call_count += 1
        raise Bunny::NetworkFailure.new('Fail', nil) if call_count == 1
      end

      expect(described_class).to receive(:sleep).once
      expect(described_class.start).to eq(bunny_session)
    end

    it 'desiste após 4 tentativas' do
      allow(bunny_session).to receive(:start).and_raise(Bunny::NetworkFailure.new('Fail', nil))

      expect { described_class.start }.to raise_error(Bunny::NetworkFailure)
      expect(described_class).to have_received(:sleep).exactly(4).times
    end
  end

  describe '.channel' do
    it 'cria um canal usando a conexão' do
      # Reseta a variável de classe para garantir teste limpo
      described_class.instance_variable_set(:@channel, nil)

      expect(described_class.channel).to eq(channel)
    end
  end
end
