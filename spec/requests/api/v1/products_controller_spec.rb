# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  # Mock dos Use Cases para isolar o Controller
  let(:create_service) { instance_double(CreateProduct) }
  let(:find_service) { instance_double(FindProductById) }
  let(:find_category_service) { instance_double(FindProductsByCategory) }
  let(:update_service) { instance_double(UpdateProduct) }
  let(:delete_service) { instance_double(DeleteProduct) }

  # Mock do Produto para retorno
  let(:product_mock) { Product.new(id: 1, name: 'Burger', category: 'Lanches', price: 20.0, quantity: 10) }

  before do
    allow(CreateProduct).to receive(:new).and_return(create_service)
    allow(FindProductById).to receive(:new).and_return(find_service)
    allow(FindProductsByCategory).to receive(:new).and_return(find_category_service)
    allow(UpdateProduct).to receive(:new).and_return(update_service)
    allow(DeleteProduct).to receive(:new).and_return(delete_service)
  end

  describe 'POST /api/v1/create_product' do
    let(:valid_params) { { name: 'Burger', category: 'Lanches', price: 20.0, quantity: 10, description: 'Yummy' } }

    context 'com parâmetros válidos' do
      before do
        allow(create_service).to receive(:call).and_return(product_mock)
      end

      it 'cria um produto e retorna 201 Created' do
        post '/api/v1/create_product', params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['successful']).to be true
      end
    end

    context 'quando o serviço falha' do
      before do
        allow(create_service).to receive(:call).and_raise(StandardError.new('Erro ao criar'))
      end

      it 'retorna 422 Unprocessable Entity' do
        post '/api/v1/create_product', params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Erro ao criar')
      end
    end
  end

  describe 'GET /api/v1/product/:product_id' do
    context 'quando o produto existe' do
      before do
        allow(find_service).to receive(:call).with(id: '1').and_return(product_mock)
      end

      it 'retorna o produto' do
        get '/api/v1/product/1'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['response']['name']).to eq('Burger')
      end
    end

    context 'quando o produto não existe' do
      before do
        allow(find_service).to receive(:call).with(id: '999').and_return(nil)
      end

      it 'retorna 404 Not Found' do
        get '/api/v1/product/999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/v1/products_by_category/:category' do
    context 'quando existem produtos' do
      before do
        allow(find_category_service).to receive(:call).with(category_name: 'Lanches').and_return([product_mock])
      end

      it 'retorna a lista' do
        get '/api/v1/products_by_category/Lanches'
        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['response']).to be_an(Array)
      end
    end

    context 'quando não existem produtos' do
      before do
        allow(find_category_service).to receive(:call).with(category_name: 'Vazio').and_return([])
      end

      it 'retorna 404' do
        get '/api/v1/products_by_category/Vazio'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/update_product/:product_id' do
    let(:params) { { price: 25.0 } }

    context 'sucesso' do
      before do
        allow(update_service).to receive(:call).and_return(product_mock)
      end

      it 'atualiza e retorna 200' do
        patch '/api/v1/update_product/1', params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'produto não encontrado (ActiveRecord error)' do
      before do
        allow(update_service).to receive(:call).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'retorna 404' do
        patch '/api/v1/update_product/999', params: params
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/remove_product_from_catalog/:product_id' do
    context 'sucesso' do
      before do
        allow(delete_service).to receive(:call).with(id: '1').and_return(true)
      end

      it 'deleta e retorna 204' do
        delete '/api/v1/remove_product_from_catalog/1'
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'falha' do
      before do
        allow(delete_service).to receive(:call).with(id: '999').and_return(false)
      end

      it 'retorna 404' do
        delete '/api/v1/remove_product_from_catalog/999'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
