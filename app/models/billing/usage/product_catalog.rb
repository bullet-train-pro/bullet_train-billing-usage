class Billing::Usage::ProductCatalog
  def initialize(parent)
    @parent = parent
  end

  def self.all_products
    Billing::Product.all
  end

  def current_products
    products = non_zero_included_prices.map(&:price).compact.map(&:product).compact
    products.any? ? products : free_products
  end

  # e.g. [[1, "day"], [5, "minutes"]]
  def cycles
    self.class.all_products
      .map(&:limits).compact.flatten
      .map(&:values).flatten # get the limits without the relationships
      .map(&:values).flatten # get the limites without the verbs
      .select { |limit| limit.key?("duration") }.map { |limit| [limit["duration"], limit["interval"]] }
      .uniq
  end

  def free_products
    [Billing::Product.find(:free)]
  end

  protected

  attr_reader :parent

  def non_zero_included_prices
    parent
      .team
      .billing_subscriptions
      .active
      .flat_map(&:included_prices)
      .select{ |included_price| included_price.quantity && included_price.quantity > 0 }
  end
end
