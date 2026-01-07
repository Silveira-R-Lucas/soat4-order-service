# SOAT4 - Order Service (Microsserviço de Pedidos) - Fase 04

O Order Service é o microsserviço central do ecossistema de autoatendimento da lanchonete SOAT. Ele é responsável pela gestão do catálogo de produtos, manipulação do carrinho de compras e orquestração do fluxo de pedidos, comunicando-se de forma assíncrona com os serviços de Pagamento e Cozinha.

## 🚀 Tecnologias e Dependências
Linguagem: Ruby 3.2.2.

Framework: Rails 7.0.10 (API Mode).

Base de Dados: PostgreSQL (Produção/Teste).

Mensageria: RabbitMQ (via gem bunny) para comunicação entre microsserviços.

Qualidade: SonarCloud, RuboCop e Brakeman (Segurança).

Cache/Real-time: Redis (configurado para Action Cable em produção).

## 🏗️ Arquitetura e Organização
O projeto utiliza os princípios de Arquitetura Limpa (Clean Architecture) e Arquitetura Hexagonal, segregando as responsabilidades em camadas:

Domain: Contém as entidades de negócio (ex: Cart, Product) e as regras fundamentais.

Use Cases: Implementa as ações específicas do sistema (ex: AddProductToCart, CheckoutCart).

Ports: Interfaces que definem como o domínio interage com o mundo externo (ex: ProductRepository).

Infrastructure: Adaptadores concretos para persistência (ActiveRecord), mensagens (RabbitMQ) e APIs externas.

## 📥 Consumo de Mensagens (Consumers)
Diferente da fase anterior, o processamento de eventos de pagamento agora é assíncrono. O serviço possui um Consumer dedicado que monitoriza a fila order-service.pagamento.

Evento PagamentoAprovado: Atualiza o status do pedido para "recebido" e inicia o fluxo de produção.

Evento PagamentoRecusado: Marca o pedido com falha no pagamento para intervenção ou nova tentativa.

## 🛠️ Configuração e Instalação
O projeto inclui um script de setup automatizado que prepara as dependências e o banco de dados:

Bash
```
# Instala gemas e prepara o banco de dados (idempotente)
./bin/setup

# Para execução via Docker local (Development):
docker-compose up --build
```

## 🧪 Testes e Cobertura
Utilizamos o RSpec para garantir a integridade dos Use Cases, Entidades e Controllers. A cobertura de código é monitorizada pelo SimpleCov e integrada ao SonarCloud.

Executar Testes: bundle exec rspec.

Cobertura Mínima: 80%.

## 🎡 Pipeline de CI/CD
O pipeline no GitHub Actions automatiza o ciclo de vida do código:

Test-and-analyze: Executa linting (RuboCop), scan de segurança (Brakeman), testes (RSpec) e análise no SonarCloud.

Build-and-push: Em caso de sucesso na main, constrói a imagem Docker e envia para o Amazon ECR.

Secrets Update: Atualiza automaticamente as tags de imagem e chaves mestras no AWS Secrets Manager.

## ⚓ Deployment no Kubernetes
O microsserviço é implantado no Amazon EKS através de dois componentes distintos:

API (Web): Deployment escalável com 2 réplicas para atender requisições HTTP na porta 3000.

Consumer (Worker): Deployment dedicado a processar mensagens do RabbitMQ em background.

As rotas da API estão expostas via Ingress sob o prefixo /api/v1/
