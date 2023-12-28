module SmApproval  
  extend ActiveSupport::Concern
  included do
    has_one :sm_unapproved_record, :as => :sm_approvable

    after_create :on_create_create_sm_unapproved_record
    after_destroy :on_destory_remove_sm_unapproved_records
    after_update :on_update_remove_sm_unapproved_records
  end

  def on_create_create_sm_unapproved_record
    if approval_status == 'U'
      SmUnapprovedRecord.create!(:sm_approvable => self)
    end
  end

  def on_destory_remove_sm_unapproved_records
    if approval_status == 'U'
      sm_unapproved_record.delete
    end
  end
  
  def on_update_remove_sm_unapproved_records
    if approval_status == 'A' and approval_status_was == 'U'
      sm_unapproved_record.delete
    end
  end 
  
end