module SmUnapprovedRecordsHelper
  def filter_records(records)
    result = []
    SmUnapprovedRecord::SM_TABLES.each do |record|
      count = SmUnapprovedRecord.where("sm_approvable_type =?", record).count 
      result << {:record_type => record, :record_count => count}
    end
    result
  end
end


