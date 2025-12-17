require 'rails_helper'

RSpec.describe RabbitmqPublisher do
  let(:channel) { instance_double(Bunny::Channel) }
  let(:exchange) { instance_double(Bunny::Exchange) }
  
  subject { described_class.new("my_exchange") }

  before do
    allow(RabbitmqConnection).to receive(:channel).and_return(channel)
    allow(channel).to receive(:fanout).with("my_exchange", durable: true).and_return(exchange)
  end

  describe '#publish' do
    it 'envia a mensagem formatada para o exchange' do
      expect(exchange).to receive(:publish) do |json_msg|
        data = JSON.parse(json_msg)
        expect(data['event']).to eq('MeuEvento')
        expect(data['payload']).to eq({ 'id' => 1 })
        expect(data['timestamp']).not_to be_nil
      end

      subject.publish('MeuEvento', { id: 1 })
    end
  end
end