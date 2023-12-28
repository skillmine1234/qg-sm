class SmBank < ActiveRecord::Base
  include Approval
  include SmApproval
  include ServiceNotification
  
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  has_many :sm_bank_accounts, :primary_key => 'code', :foreign_key => 'sm_code', :class_name => 'SmBankAccount'

  validates_presence_of :code, :name, :bank_code, :identity_user_id, :neft_allowed, :imps_allowed, :is_enabled

  validates :code, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}' }, length: {maximum: 20}
  validates :name, format: {with: /\A[a-z|A-Z|0-9|\s|\.|\-]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\s|\.|\-]}' }, length: {maximum: 100}
  # validates :bank_code, format: {with: /\A[A-Z]{4}[0][A-Z]{3}[A-Z|0-9]{3}+\z/, message: "invalid format - expected format is : {[A-Z]{4}[0][A-Z]{3}[A-Z|0-9]{3}}" }
  validates :low_balance_alert_at, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => '9e20'.to_f }
  validates :identity_user_id, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}'}, length: {maximum: 20}

  validate :presence_of_iam_cust_user

  validates_uniqueness_of :code, :scope => :approval_status

  def imps_allowed?
    imps_allowed == "Y" ? true : false
  end

  def presence_of_iam_cust_user
    errors.add(:identity_user_id, 'IAM Customer User does not exist for this username') unless IamCustUser.iam_cust_user_exists?
  end

  def template_variables
    user = IamCustUser.find_by(username: identity_user_id)
    { username: user.try(:username), first_name: user.try(:first_name), last_name: user.try(:last_name), mobile_no: user.try(:mobile_no),
      email: user.try(:email), service_name: 'DomesticRemittance', partner_code: code, customer_id: sm_bank_accounts.first.try(:customer_id),
      account_no: sm_bank_accounts.first.try(:account_no) }
  end
end