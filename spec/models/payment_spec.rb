require 'rails_helper'

describe Payment do
  describe '.update_invoices_balance!' do
    it 'splits payments amount on not canceled invoices' do
      member = create(:member, :active)
      beginning_of_year = Time.current.beginning_of_year
      invoice1 = create(:invoice,
        date: beginning_of_year,
        member: member,
        membership: member.current_membership,
        memberships_amount_description: 'Montant #1',
        membership_amount_fraction: 3)
      invoice2 = create(:invoice,
        date: beginning_of_year + 1.day,
        member: member,
        membership: member.current_membership,
        memberships_amount_description: 'Montant #2',
        membership_amount_fraction: 2)
      invoice3 = create(:invoice, :canceled,
        date: beginning_of_year + 2.days,
        member: member,
        membership: member.current_membership,
        memberships_amount_description: 'Montant #3',
        membership_amount_fraction: 1)
      invoice3_bis = create(:invoice,
        date: beginning_of_year + 3.days,
        member: member,
        membership: member.current_membership,
        memberships_amount_description: 'Montant #3',
        membership_amount_fraction: 1)
      create(:payment, member: member, amount: 1100)

      Payment.update_invoices_balance!(member)

      expect(invoice1.reload.balance).to eq 400
      expect(invoice1.state).to eq 'closed'
      expect(invoice2.reload.balance).to eq 400
      expect(invoice2.state).to eq 'closed'
      expect(invoice3.reload.balance).to eq 0
      expect(invoice3.state).to eq 'canceled'
      expect(invoice3_bis.reload.balance).to eq 300
      expect(invoice3_bis.state).to eq 'not_sent'
    end
  end
end