ActiveAdmin.register Payment do
  menu parent: 'Facturation', priority: 2
  actions :all

  scope :all, default: true
  scope :isr
  scope :manual

  includes :member, :invoice
  index do
    column :id
    column :date, ->(p) { l p.date, format: :number }
    column :member, sortable: 'members.name'
    column :invoice_id, ->(p) { p.invoice_id ? auto_link(p.invoice, p.invoice_id) : '–' }
    column :amount, ->(p) { number_to_currency(p.amount) }
    column :type, ->(p) { status_tag p.type }
    actions
  end

  csv do
    column :id
    column :date
    column :amount
    column :member_id
    column :invoice_id
    column :type
  end

  filter :id, as: :numeric
  filter :member,
    as: :select,
    collection: -> { Member.joins(:payments).order(:name).distinct }
  filter :invoice_id, as: :numeric
  filter :date

  sidebar I18n.t('active_admin.sidebars.total'), only: :index do
    all = collection.limit(nil)
    span t('active_admin.sidebars.amount')
    span number_to_currency(all.sum(:amount)), style: 'float: right; font-weight: bold;'
  end

  show do |payement|
    attributes_table title: 'Détails' do
      row :id
      row :member
      row :invoice
      row(:date) { l payement.date }
      row(:amount) { number_to_currency(payement.amount) }
      row(:created_at) { l payement.created_at }
      row(:updated_at) { l payement.updated_at }
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'Details' do
      f.input :member, collection: Member.order(:name).distinct, include_blank: false
      f.input :date, as: :datepicker, include_blank: false
      f.input :amount, as: :number, min: 0, max: 99999.95, step: 0.05
      unless f.object.persisted?
        f.input :comment, as: :text
      end
    end
    f.actions
  end

  permit_params(*%i[member_id date amount comment])

  before_build do |payment|
    payment.member_id ||= referer_filter_member_id
    payment.date ||= Date.current
    payment.amount ||= 0
  end

  after_create do |payment|
    if payment.comment.present?
      ActiveAdmin::Comment.create!(
        resource: payment,
        body: payment.comment,
        author: current_admin,
        namespace: 'root')
    end
  end

  config.sort_order = 'date_desc'
  config.per_page = 50
end
