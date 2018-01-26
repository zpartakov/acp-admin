require 'rails_helper'

describe Basket do
  it 'sets prices on creation' do
    basket = create(:basket,
      basket_size: create(:basket_size, price: 30),
      distribution: create(:distribution, price: 5))

    expect(basket.basket_price).to eq 30
    expect(basket.distribution_price).to eq 5
  end

  it 'updates price when other prices change' do
    basket = create(:basket,
      basket_size: create(:basket_size, price: 30),
      distribution: create(:distribution, price: 5))

    basket.update!(basket_size_id: create(:basket_size, price: 35).id)
    expect(basket.basket_price).to eq(35)

    basket.update!(distribution: create(:distribution, price: 2))
    expect(basket.distribution_price).to eq(2)
  end

  it 'updates basket complement_prices when created' do
    basket = create(:basket)
    create(:basket_complement, id: 42, price: 3.21)

    expect {
      basket.update!(basket_complement_ids: [42])
    }.to change { basket.reload.complement_prices }.from({}).to(42 => BigDecimal('3.21'))
  end

  it 'removes basket complement_prices when destroyed' do
    basket = create(:basket)
    create(:basket_complement, id: 42, price: 3.21)
    create(:basket_complement, id: 47, price: 4.56)
    basket.update!(basket_complement_ids: [47, 42])

    expect {
      basket.update!(basket_complement_ids: [47])
    }.to change { basket.reload.complement_prices }
      .from(42 => BigDecimal('3.21'), 47 => BigDecimal('4.56'))
      .to(47 => BigDecimal('4.56'))
  end

  it 'sets basket_complement on creation when its match membership and delivery ones' do
    create(:basket_complement, id: 1, price: 3.21)
    create(:basket_complement, id: 2, price: 4.56)

    membership_1 = create(:membership, subscribed_basket_complement_ids: [1, 2])
    membership_2 = create(:membership, subscribed_basket_complement_ids: [2])
    delivery = create(:delivery, basket_complement_ids: [1, 2])

    basket = create(:basket, membership: membership_1, delivery: delivery)
    expect(basket.basket_complement_ids).to eq [1, 2]
    expect(basket[:complement_prices]).to eq('1' => '3.21', '2' => '4.56')

    basket = create(:basket, membership: membership_2, delivery: delivery)
    expect(basket.basket_complement_ids).to eq [2]
    expect(basket[:complement_prices]).to eq('2' => '4.56')
  end
end
