class AddPaidMissingHaldaysWorksToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :paid_missing_haldays_works, :integer
  end
end
