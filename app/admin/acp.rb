ActiveAdmin.register ACP do
  menu parent: 'Autre', priority: 100, label: 'Paramètres'
  actions :edit, :update
  permit_params \
    :name, :host, :logo,
    :email_api_token, :email_default_host, :email_default_from,
    :trial_basket_count,
    :ccp, :isr_identity, :isr_payment_for, :isr_in_favor_of,
    :invoice_info, :invoice_footer,
    :summer_month_range_min, :summer_month_range_max,
    :fiscal_year_start_month, :support_price,
    :halfday_i18n_scope, :halfday_participation_deletion_deadline_in_days,
    :delivery_pdf_footer,
    :url, :email, :phone,
    :vat_number, :vat_membership_rate,
    billing_year_divisions: [],
    features: []

  form do |f|
    f.inputs 'Détails' do
      f.input :name
      f.input :host, hint: '*.host.*'
      f.input :logo, as: :file
    end
    f.inputs do
      f.input :features,
        as: :check_boxes,
        collection: ACP.features.map { |f| [t("activerecord.models.#{f}.one"), f] }
    end
    f.inputs 'Mailer (Postmark)' do
      f.input :email_api_token
      f.input :email_default_host
      f.input :email_default_from
    end
    f.inputs 'Abonnement' do
      f.input :trial_basket_count
    end
    f.inputs 'Saisons (été/hiver)' do
      f.input :summer_month_range_min,
        as: :select,
        collection: (1..12).map { |m| [t('date.month_names')[m], m] }
      f.input :summer_month_range_max,
        as: :select,
        collection: (1..12).map { |m| [t('date.month_names')[m], m] }
    end
    f.inputs 'Facturation' do
      f.input :fiscal_year_start_month,
        as: :select,
        collection: (1..12).map { |m| [t('date.month_names')[m], m] },
        include_blank: false
      f.input :billing_year_divisions,
        as: :check_boxes,
        collection: ACP.billing_year_divisions.map { |i| [t("billing.year_division._#{i}"), i] }
      f.input :support_price
      f.input :vat_number
      f.input :vat_membership_rate, as: :number, min: 0, max: 100, step: 0.01
    end
    f.inputs 'Facture (BVR)' do
      f.input :ccp
      f.input :isr_identity
      f.input :isr_payment_for
      f.input :isr_in_favor_of
      f.input :invoice_info
      f.input :invoice_footer
    end
    f.inputs 'Participation des membres' do
      f.input :halfday_i18n_scope,
        label: 'Appellation',
        as: :select,
        collection: ACP.halfday_i18n_scopes.map { |s| [t("halfday.#{s}", count: 2), s] },
        include_blank: false
      f.input :halfday_participation_deletion_deadline_in_days
    end
    f.inputs 'Fiches signature livraison (PDF)' do
      f.input :delivery_pdf_footer
    end
    f.inputs 'Page de membre' do
      f.input :url
      f.input :email
      f.input :phone
    end

    f.actions do
      f.submit t('active_admin.edit_model', model: resource.name)
    end
  end

  controller do
    defaults singleton: true

    def resource
      @resource ||= Current.acp
    end
  end
end
