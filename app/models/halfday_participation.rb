class HalfdayParticipation < ActiveRecord::Base
  include HalfdayNaming

  attr_reader :carpooling, :halfday_ids
  delegate :missing_participants_count, to: :halfday, allow_nil: true

  belongs_to :halfday
  belongs_to :member
  belongs_to :validator, class_name: 'Admin', optional: true
  has_many :invoices, as: :object

  scope :validated, -> { where(state: 'validated') }
  scope :rejected, -> { where(state: 'rejected') }
  scope :not_rejected, -> { where.not(state: 'rejected') }
  scope :pending, -> { joins(:halfday).merge(Halfday.past).where(state: 'pending') }
  scope :coming, -> { joins(:halfday).merge(Halfday.coming) }
  scope :past_current_year, -> { joins(:halfday).merge(Halfday.past_current_year) }
  scope :during_year, ->(year) { joins(:halfday).merge(Halfday.during_year(year)) }
  scope :carpooling, ->(date) {
    joins(:halfday).where(halfdays: { date: date }).where.not(carpooling_phone: nil)
  }

  validates :halfday, presence: true, uniqueness: { scope: :member_id }
  validates :participants_count,
    presence: true,
    numericality: {
      less_than_or_equal_to: :missing_participants_count,
      if: :missing_participants_count
    },
    unless: :validated_at?

  before_create :set_carpooling_phone
  after_update :send_notifications
  after_commit :update_membership_recognized_halfday_works!

  def coming?
    pending? && halfday.date > Date.current
  end

  def state
    coming? ? 'coming' : super
  end

  %w[validated rejected pending].each do |state|
    define_method "#{state}?" do
      self[:state] == state
    end
  end

  def value
    participants_count
  end

  def carpooling_phone=(phone)
    super PhonyRails.normalize_number(phone, default_country_code: 'CH')
  end

  def carpooling=(carpooling)
    @carpooling = carpooling == '1'
  end

  def carpooling?
    carpooling_phone
  end

  def destroyable?
    deadline = Current.acp.halfday_participation_deletion_deadline_in_days
    !deadline || created_at > 1.day.ago || halfday.date > deadline.days.from_now
  end

  def reminderable?
    return unless coming?

    (halfday.date < 2.weeks.from_now && !latest_reminder_sent_at && created_at < 1.month.ago) ||
      (halfday.date < 3.days.from_now && (!latest_reminder_sent_at || latest_reminder_sent_at < 1.week.ago))
  end

  def validate!(validator)
    return if coming?
    update!(
      state: 'validated',
      validated_at: Time.current,
      validator: validator,
      rejected_at: nil)
  end

  def reject!(validator)
    return if coming?
    update!(
      state: 'rejected',
      rejected_at: Time.current,
      validator: validator,
      validated_at: nil)
  end

  def self.send_reminder_emails
    coming.select(&:reminderable?).each do |hp|
      HalfdayParticipationMailer.reminder(hp).deliver_now
      hp.touch(:latest_reminder_sent_at)
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { emails: hp.member.emails, member: hp.member })
    end
  end

  private

  def set_carpooling_phone
    if @carpooling
      if carpooling_phone.blank?
        self.carpooling_phone = member.phones_array.first
      end
    else
      self.carpooling_phone = nil
    end
  end

  def update_membership_recognized_halfday_works!
    member.membership(halfday.fy_year)&.update_recognized_halfday_works!
  end

  def send_notifications
    if saved_change_to_validated_at? && validated_at?
      HalfdayParticipationMailer.validated(self).deliver_now
    end
    if saved_change_to_rejected_at? && rejected_at?
      HalfdayParticipationMailer.rejected(self).deliver_now
    end
  rescue => ex
    ExceptionNotifier.notify_exception(ex,
      data: { emails: member.emails, member: member })
  end
end
