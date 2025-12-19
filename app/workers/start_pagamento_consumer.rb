# frozen_string_literal: true

class StartPagamentoConsumer
  def self.run
    RabbitmqConsumer.new('pagamento.events', 'order-service.pagamento').start_listening
  end
end
