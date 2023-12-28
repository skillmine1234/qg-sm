class SmPayment < ActiveRecord::Base
  include SearchAbility
  
  attr_searchable :req_no, :customer_id, :status_code, :attempt_no, :transfer_type, :partner_code, :debit_account_no, :rmtr_account_no, :rmtr_account_ifsc, :bene_account_no, :bank_ref_no, {req_timestamp: :range}, {rep_timestamp: :range} 

  has_many :audit_steps, :class_name => 'SmAuditStep', :as => :sm_auditable
  has_one :audit_log, class_name: 'SmAuditLog', :as => :sm_auditable
  
  as_enum :status_code, [:'FAILED', :'COMPLETED', :'IN_PROCESS', :'SENT_TO_BENEFICIARY', :'RETURNED_FROM_BENEFICIARY', :'SCHEDULED_FOR_NEXT_WORKDAY'], map: :string, source: :status_code
  as_enum :transfer_type, [:NEFT, :IMPS, :RTGS, :FT], map: :string, source: :transfer_type
end