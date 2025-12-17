FactoryBot.define do
  factory :cart_item, class: 'CartItem' do
    id { Faker::Number.unique.number(digits: 4) }
    cart_id { Faker::Number.number(digits: 4) }
    quantity { Faker::Number.between(from: 1, to: 5) }
    product_id { Faker::Number.unique.number(digits: 4) }
    product_name { Faker::Food.dish }
    product_price { Faker::Commerce.price(range: 10.0..50.0).to_f }

    initialize_with { new(attributes) }
  end
end