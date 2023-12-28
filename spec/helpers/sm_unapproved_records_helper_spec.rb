require 'spec_helper'

describe SmUnapprovedRecordsHelper do
  context "filter_records" do 
    it "should return records" do
      sm_unapproved_record = Factory(:sm_unapproved_record, :sm_approvable_type => 'SmBank')
      filter_records(SmUnapprovedRecord).should eq([{:record_type=>"SmBank", :record_count=>1}, {:record_type=>"SmBankAccount", :record_count=>0}])
    end
  end
end
