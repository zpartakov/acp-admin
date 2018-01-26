class BasketComplementCount
  def self.all(delivery)
    complements = BasketComplement.all
    basket_complement_ids = delivery.baskets.flat_map(&:basket_complement_ids)
    complements.map { |c|
      new(c, basket_complement_ids)
    }.select { |c| c.count.positive? }
  end

  def initialize(complement, baskets_complement_ids)
    @complement = complement
    @baskets_complement_ids = baskets_complement_ids
  end

  def title
    @complement.name
  end

  def count
    @count ||= @baskets_complement_ids.count { |id| id == @complement.id}
  end
end
