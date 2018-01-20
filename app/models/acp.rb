class ACP < ActiveRecord::Base
  FEATURES = %w[
    basket_content
    gribouille
  ]

  validates :name, presence: true
  validates :host, presence: true
  validates :tenant_name, presence: true
  validates :fiscal_year_start_month,
    presence: true,
    inclusion: { in: 1..12 }

  after_create :create_tenant

  def self.switch_each!
    ACP.pluck(:tenant_name).each do |tenant|
      Apartment::Tenant.switch!(tenant)
      Current.acp = nil
      yield
    end
  ensure
    Apartment::Tenant.reset
  end

  def feature?(feature)
    self.features.include?(feature.to_s)
  end

  def fiscal_year
    FiscalYear.current(fiscal_year_start_month)
  end

  def fiscal_year_for(year)
    FiscalYear.for(year, fiscal_year_start_month)
  end

  private

  def create_tenant
    Apartment::Tenant.create(tenant_name)
  end
end
