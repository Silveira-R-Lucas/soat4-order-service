FactoryBot.define do
  factory :product, class: 'Product' do
    id { Faker::Number.unique.number(digits: 4) }
    name { Faker::Food.dish }
    description { Faker::Food.description }
    category { %w[Lanches Bebidas Sobremesas].sample }
    price { Faker::Commerce.price(range: 10.0..50.0).to_f }
    quantity { Faker::Number.between(from: 10, to: 100) }
    initialize_with { new(attributes) }
  end
end