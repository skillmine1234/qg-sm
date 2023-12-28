class SmAuditStep < ActiveRecord::Base
  belongs_to :sm_auditable, :polymorphic => true

  lazy_load :req_bitstream, :rep_bistream, :fault_bitstream

  as_enum :status_code, [:NEW, :FAILED, :COMPLETED, :'TIMED OUT'], map: :string, source: :status_code  
end
