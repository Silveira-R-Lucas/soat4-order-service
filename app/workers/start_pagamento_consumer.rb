# frozen_string_literal: true

RabbitmqConsumer.new('pagamento.events', 'order-service.pagamento').start_listening
