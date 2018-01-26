class Basket < ActiveRecord::Base
  acts_as_paranoid

  default_scope { joins(:delivery).order('deliveries.date') }

  delegate :next?, :delivered?, to: :delivery

  belongs_to :membership, counter_cache: true, touch: true
  belongs_to :delivery
  belongs_to :basket_size
  belongs_to :distribution
  has_one :member, through: :membership
  has_and_belongs_to_many :basket_complements,
    after_add: :set_complement_price,
    after_remove: :delete_complement_price

  before_create :add_complements
  before_save :set_prices

  scope :current_year, -> { joins(:delivery).merge(Delivery.current_year) }
  scope :delivered, -> { joins(:delivery).merge(Delivery.past) }
  scope :coming, -> { joins(:delivery).merge(Delivery.coming) }
  scope :between, ->(range) { joins(:delivery).merge(Delivery.between(range)) }
  scope :absent, -> { where(absent: true) }
  scope :not_absent, -> { where(absent: false) }

  def description
    txt = basket_size.name
    if basket_complements.any?
      txt += ' + '
      txt += basket_complements.map(&:name).to_sentence
    end
    txt
  end

  def complement_prices
    self[:complement_prices].map { |id, price| [id.to_i, BigDecimal(price)] }.to_h
  end

  def complement?(complement)
    basket_complements.exists?(complement.id)
  end

  def add_complement!(complement)
    return if complement?(complement)

    self.basket_complements.push(complement)
    save! # set complement_prices
  end

  def remove_complement!(complement)
    return unless complement?(complement)

    self.basket_complements.destroy(complement)
    save! # set complement_prices
  end

  private

  def add_complements
    self.basket_complement_ids =
      delivery.basket_complement_ids & membership.subscribed_basket_complement_ids
  end

  def set_prices
    self.basket_price = basket_size.price if basket_size_id_changed?
    self.distribution_price = distribution.price if distribution_id_changed?
  end

  def set_complement_price(complement)
    self[:complement_prices][complement.id] = complement.price
  end

  def delete_complement_price(complement)
    self.complement_prices = complement_prices.delete_if { |k,_| k == complement.id }
  end
end
