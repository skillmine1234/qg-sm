class SmBankAccount < ActiveRecord::Base
  include Approval
  include SmApproval
  
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  belongs_to :sm_bank, :foreign_key => 'sm_code', :primary_key => 'code'

  validates_presence_of :sm_code, :customer_id, :account_no, :is_enabled

  validates :sm_code, format: {with: /\A[a-z|A-Z|0-9]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9]}' }, length: { maximum: 20 }
  validates :customer_id, format: {with: /\A[0-9]+\z/, :message => 'Invalid format, expected format is : {[0-9]}'}, length: { minimum: 3, maximum: 15 }
  validates :account_no, format: {with: /\A[0-9]+\z/, :message => 'Invalid format, expected format is : {[0-9]}' }, length: { minimum: 1, maximum: 15 }

  validates :mmid, presence: true, format: {with: /\A[0-9]{7}+\z/, :message => 'Invalid format, expected format is : {[0-9]{7}}'}, length: { minimum: 7, maximum: 7 }, if: :is_mmid_and_mobile_no_mandatory?
  validates :mobile_no, presence: true, format: {with: /\A[0-9]{10}+\z/, :message => 'Invalid format, expected format is : {[0-9]{10}}'}, length: {maximum: 10, minimum: 10}, if: :is_mmid_and_mobile_no_mandatory?
  
  validates_uniqueness_of :sm_code, :scope => [:customer_id, :account_no, :approval_status]
  validates_uniqueness_of :account_no, :scope => [:approval_status]

  validate :validate_customer_id
  validate :validate_sm_code
  validate :is_mmid_and_mobile_no_mandatory?
  validate :validate_account, if: -> {"sm_bank.present? && sm_bank.imps_allowed=='Y'"}
  validate :validate_customer_with_fcr, if: -> {"sm_bank.present? && sm_bank.neft_allowed=='Y'"}

  def validate_customer_id
    sm_bank_accounts = SmBankAccount.where("customer_id = ?", customer_id)
    if !sm_bank_accounts.empty?
      matching_sm_bank_accounts = sm_bank_accounts.select{|sm_bank_account| sm_bank_account.sm_code == sm_code}
      errors.add(:customer_id, "already exists with different sub member bank") if matching_sm_bank_accounts.empty?
    end
  end

  def validate_sm_code
    errors.add(:sm_code, "is not present in bank") if self.sm_bank.nil?
  end

  def is_mmid_and_mobile_no_mandatory?
    (sm_bank.imps_allowed? ? true : false) if !sm_bank.nil?
  end
  
  def validate_customer_with_fcr
    fcr_customer = Fcr::Customer.find_by_cod_cust_id(self.customer_id)
    if fcr_customer.nil?
      errors.add(:customer_id, "no record found in FCR for #{self.customer_id}")
    else
      errors[:base] << "Required setup for NEFT transfer not found in FCR for #{self.customer_id}" unless fcr_customer.transfer_type_allowed?('NEFT')
    end
  end

  def validate_account
    fcr_customer = Fcr::Customer.find_by_cod_cust_id(self.customer_id)
    atom_customer_by_debit_acct = Atom::Customer.find_by_accountno(self.account_no)

    if fcr_customer.present? && atom_customer_by_debit_acct.present?
      errors.add(:account_no, "Required setup for IMPS transfer not found in ATOM for #{self.account_no}") unless atom_customer_by_debit_acct.imps_allowed?(fcr_customer.ref_phone_mobile)
    else
      errors.add(:customer_id, "no record found in FCR for #{self.customer_id}") if fcr_customer.nil?
      errors.add(:account_no, "no record found in ATOM for #{self.account_no}") if atom_customer_by_debit_acct.nil?
    end
  end
end