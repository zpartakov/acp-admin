class MailChimp
  def initialize
    @config = Current.acp.credentials(:mailchimp)
    @list_id = @config.fetch(:list_id)
  end

  def upsert_member(member = nil)
    member.emails_array.each do |email|
      hash_id = hash_id(email)
      body = {
        email_address: email,
        merge_fields: member_merge_fields(member)
      }
      body[:status] = 'subscribed' unless hash_id.in?(all_hash_ids)
      client.lists(@list_id).members(hash_id).upsert(body: body)
    end
  end

  def update_unsubscribed_members
    unsubscribed_hash_ids = get_hash_ids(status: 'unsubscribed')
  end

  def remove_deleted_members(members)
    member_hash_ids = members.flat_map(&:emails_array).map { |e| hash_id(e) }
    hash_ids_to_delete = get_hash_ids - member_hash_ids
    hash_ids_to_delete.each do |hash_id|
      client.lists(@list_id).members(hash_id).delete
    end
  end

  def client
    @client ||= Gibbon::Request.new(
      api_key: @config.fetch(:api_key),
      symbolize_keys: true)
  end

  def all_hash_ids
    @all_hash_ids ||= get_hash_ids
  end

  def subscribed_hash_ids
    @subscribed_hash_ids ||= get_hash_ids(status: 'subscribed')
  end

  def get_hash_ids(status: nil)
    params = { fields: 'members.id', count: 1000 }
    params[:status] = status if status
    client.lists(@list_id).members.retrieve(params: params)
      .body[:members].map { |m| m[:id] }
  end

  def member_merge_fields(member)
    basket = member.baskets.coming.first
    {
      MEMB_NAME: member.name,
      MEMB_PAGE: [Current.acp.email_default_host, member.token].join('/'),
      BASK_SIZE: basket.basket_size&.name.to_s,
      BASK_DIST: basket.distribution&.name.to_s,
      BASK_COMP: basket.membership.subscribed_basket_complements.map(&:name).join(', ')
    }
  end

  def hash_id(email)
    Digest::MD5.hexdigest(email.downcase)
  end

  def setup_merge_fields
    exiting_fields =
      client.lists(@list_id).merge_fields.retrieve
        .body[:merge_fields].map { |m| [m[:tag], m[:merge_id]] }.to_h
    fields = {
      MEMB_NAME: { name: 'Nom', type: 'text' },
      MEMB_PAGE: { name: 'Page de membre URL', type: 'url' },
      BASK_SIZE: { name: 'Taille panier', type: 'text', default_value: '' },
      BASK_DIST: { name: 'Distribution', type: 'text', default_value: '' },
      BASK_COMP: { name: 'Compléments panier', type: 'text', default_value: '' }
    }
    fields.each do |tag, attrs|
      attrs.merge!(tag: tag.to_s, public: false, required: true)
      if id = exiting_fields[tag.to_s]
        client.lists(@list_id).merge_fields(id).update(body: attrs)
      else
        client.lists(@list_id).merge_fields.create(body: attrs)
      end
    end
  end
end
