class SmAuditLog < ActiveRecord::Base
  belongs_to :sm_auditable, :polymorphic => true

  lazy_load :req_bitstream, :rep_bistream, :fault_bitstream
end
