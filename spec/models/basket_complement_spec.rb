require 'rails_helper'

describe BasketComplement do
  it 'adds basket_complement on subscribed baskets' do
    basket_complement1 = create(:basket_complement, id: 1, price: 3.21)
    basket_complement2 = create(:basket_complement, id: 2, price: 4.56)

    membership_1 = create(:membership, subscribed_basket_complement_ids: [1, 2])
    membership_2 = create(:membership, subscribed_basket_complement_ids: [2])
    membership_3 = create(:membership, subscribed_basket_complement_ids: [1])

    delivery = create(:delivery)

    basket1 = create(:basket, membership: membership_1, delivery: delivery)
    basket2 = create(:basket, membership: membership_2, delivery: delivery)
    basket3 = create(:basket, membership: membership_3, delivery: delivery)
    basket3.update!(basket_complement_ids: [1, 2])

    basket_complement1.update!(delivery_ids: [delivery.id])
    basket_complement2.update!(delivery_ids: [delivery.id])

    basket1.reload
    expect(basket1.basket_complement_ids).to eq [1, 2]
    expect(basket1[:complement_prices]).to eq('1' => '3.21', '2' => '4.56')

    basket2.reload
    expect(basket2.basket_complement_ids).to eq [2]
    expect(basket2[:complement_prices]).to eq('2' => '4.56')

    basket3.reload
    expect(basket3.basket_complement_ids).to eq [1, 2]
    expect(basket3[:complement_prices]).to eq('1' => '3.21', '2' => '4.56')
  end

  it 'removes basket_complement on subscribed baskets' do
    basket_complement1 = create(:basket_complement, id: 1, price: 3.21)
    basket_complement2 = create(:basket_complement, id: 2, price: 4.56)

    membership_1 = create(:membership, subscribed_basket_complement_ids: [1, 2])
    membership_2 = create(:membership, subscribed_basket_complement_ids: [2])
    membership_3 = create(:membership, subscribed_basket_complement_ids: [1])

    delivery = create(:delivery, basket_complement_ids: [1, 2])

    basket1 = create(:basket, membership: membership_1, delivery: delivery)
    basket2 = create(:basket, membership: membership_2, delivery: delivery)
    basket3 = create(:basket, membership: membership_3, delivery: delivery)
    basket3.update!(basket_complement_ids: [1, 2])

    basket_complement2.update!(delivery_ids: [])

    basket1.reload
    expect(basket1.basket_complement_ids).to eq [1]
    expect(basket1[:complement_prices]).to eq('1' => '3.21')

    basket2.reload
    expect(basket2.basket_complement_ids).to be_empty
    expect(basket2[:complement_prices]).to be_empty

    basket3.reload
    expect(basket3.basket_complement_ids).to eq [1, 2]
    expect(basket3[:complement_prices]).to eq('1' => '3.21', '2' => '4.56')
  end
end
