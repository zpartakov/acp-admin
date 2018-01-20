class Current < ActiveSupport::CurrentAttributes
  attribute :acp

  delegate :fiscal_year, to: :acp

  def acp
    unless super
      self.acp = ACP.find_by!(tenant_name: Apartment::Tenant.current)
    end
    super
  end
end
