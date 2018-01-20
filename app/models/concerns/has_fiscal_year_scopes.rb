module HasFiscalYearScopes
  extend ActiveSupport::Concern

  included do
    scope :past_year, -> { where('date < ?', Current.fiscal_year.beginning_of_year) }
    scope :current_year, -> { where(date: Current.fiscal_year.range) }
    scope :future_year, -> { where('date < ?', Current.fiscal_year.end_of_year) }
  end
end
