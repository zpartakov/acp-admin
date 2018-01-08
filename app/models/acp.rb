class ACP < ActiveRecord::Base
  validates :name, presence: true
  validates :host, presence: true
  validates :tenant_name, presence: true

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

  private

  def create_tenant
    Apartment::Tenant.create(tenant_name)
  end
end
