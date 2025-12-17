require 'rails_helper'

RSpec.describe "Api::V1::Carts", type: :request do
  # Mock dos serviços
  let(:get_or_create_cart) { instance_double(GetOrCreateClientCart) }
  let(:add_item_service) { instance_double(AddProductToCart) }
  let(:remove_item_service) { instance_double(RemoveProductFromCart) }
  let(:update_item_service) { instance_double(UpdateProductQuantityInCart) }
  let(:update_status_service) { instance_double(UpdateCartStatus) }
  let(:publisher) { instance_double(RabbitmqPublisher) }

  # Mock do carrinho
  let(:cart_mock) do
    Cart.new(id: 1, client_id: 1, total_price: 100.0, status: 'novo', payment_status: 'pendente', items: [])
  end

  before do
    allow(GetOrCreateClientCart).to receive(:new).and_return(get_or_create_cart)
    allow(AddProductToCart).to receive(:new).and_return(add_item_service)
    allow(RemoveProductFromCart).to receive(:new).and_return(remove_item_service)
    allow(UpdateProductQuantityInCart).to receive(:new).and_return(update_item_service)
    allow(UpdateCartStatus).to receive(:new).and_return(update_status_service)
    allow(RabbitmqPublisher).to receive(:new).and_return(publisher)

    # Setup padrão: Recuperar carrinho (usado no before_action)
    allow(get_or_create_cart).to receive(:call).and_return(cart_mock)
  end

  describe "POST /api/v1/cart/add_item" do
    let(:params) { { product_id: '10', quantity: '2', client_id: '1' } }

    it "adiciona item com sucesso" do
      expect(add_item_service).to receive(:call).with(client_id: '1', product_id: '10', quantity: '2', cart: cart_mock).and_return(cart_mock)
      
      post "/api/v1/cart/add_item", params: params
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to include("sucesso")
    end

    it "retorna erro 422 se serviço falhar" do
      allow(add_item_service).to receive(:call).and_raise(ArgumentError.new("Qtd inválida"))
      
      post "/api/v1/cart/add_item", params: params
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/cart" do
    it "retorna os detalhes do carrinho" do
      get "/api/v1/cart", params: { client_id: 1 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['response']['id']).to eq(1)
    end
  end

  describe "POST /api/v1/cart/create_payment" do
    before do
      allow(cart_mock).to receive(:to_h_payment_display).and_return({})
    end

    it "publica evento e retorna sucesso" do
      expect(publisher).to receive(:publish).with("CarrinhoFinalizado", anything).and_return(true)
      
      post "/api/v1/cart/create_payment", params: { client_id: 1 }
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['payment_status']).to eq('creating_payment')
    end
  end

  describe "DELETE /api/v1/cart/remove_item" do
    it "remove item com sucesso" do
      expect(remove_item_service).to receive(:call).and_return(cart_mock)
      
      delete "/api/v1/cart/remove_item", params: { product_id: 10, client_id: 1 }
      
      expect(response).to have_http_status(:accepted)
    end

    it "retorna 400 se faltar product_id" do
      delete "/api/v1/cart/remove_item", params: { client_id: 1 }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /api/v1/cart/update_status_in_progress_orders" do
    let(:params) { { cart_id: '1', progress_status: 'em_preparação' } }

    it "atualiza status com sucesso" do
      expect(update_status_service).to receive(:call).with(cart_id: '1', new_status: 'em_preparação').and_return(cart_mock)
      
      patch "/api/v1/cart/update_status_in_progress_orders", params: params
      
      expect(response).to have_http_status(:ok)
    end

    it "retorna 404 se carrinho não encontrado" do
      allow(update_status_service).to receive(:call).and_raise(ArgumentError.new("Cart with ID 1 not found"))
      
      patch "/api/v1/cart/update_status_in_progress_orders", params: params
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/cart/update_item" do
    let(:params) { { product_id: 10, quantity: 5, client_id: 1 } }

    it "atualiza a quantidade com sucesso" do
      expect(update_item_service).to receive(:call).and_return(cart_mock)
      
      patch "/api/v1/cart/update_item", params: params
      
      expect(response).to have_http_status(:accepted)
    end

    it "retorna 400 se parâmetros faltarem" do
      patch "/api/v1/cart/update_item", params: { client_id: 1 }
      expect(response).to have_http_status(:bad_request)
    end

    it "retorna erro 500 se algo inesperado ocorrer" do
      allow(update_item_service).to receive(:call).and_raise(StandardError.new("Boom"))
      
      patch "/api/v1/cart/update_item", params: params
      
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "GET /api/v1/cart/payment_status" do
    context "quando status é 'pago' (regex match)" do
      before do
        allow(get_or_create_cart).to receive(:call).and_return(cart_mock)
        allow(cart_mock).to receive(:payment_status).and_return('pago_aprovado')
      end

      it "retorna 202 Accepted" do
        get "/api/v1/cart/payment_status", params: { client_id: 1 }
        expect(response).to have_http_status(:accepted)
      end
    end

    context "quando status é pendente" do
      before do
        allow(get_or_create_cart).to receive(:call).and_return(cart_mock)
        allow(cart_mock).to receive(:payment_status).and_return('pendente')
      end

      it "retorna 200 OK" do
        get "/api/v1/cart/payment_status", params: { client_id: 1 }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/v1/cart/list_checked_out_orders" do
    # Mock do Use Case específico de listagem (ListCheckedOutCarts) se necessário,
    # ou testar o erro genérico do controller
    before do
      # Simulando que não precisamos instanciar o service aqui pois vamos forçar erro no controller
      # ou assumindo que o controller instancia ListCheckedOutCarts.new internamente
      list_service = instance_double(ListCheckedOutCarts)
      allow(ListCheckedOutCarts).to receive(:new).and_return(list_service)
      allow(list_service).to receive(:call).and_return([])
    end

    it "retorna lista vazia com sucesso" do
      get "/api/v1/cart/list_checked_out_orders"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/cart/list_in_progress_orders" do
    before do
      list_service = instance_double(ListInProgressCarts)
      allow(ListInProgressCarts).to receive(:new).and_return(list_service)
      allow(list_service).to receive(:call).and_return([])
    end

    it "retorna lista vazia com sucesso" do
      get "/api/v1/cart/list_in_progress_orders"
      expect(response).to have_http_status(:ok)
    end
  end
end