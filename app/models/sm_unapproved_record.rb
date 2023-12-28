class SmUnapprovedRecord < ActiveRecord::Base
  belongs_to :sm_approvable, :polymorphic => true, :unscoped => true
  SM_TABLES = ['SmBank','SmBankAccount']
end