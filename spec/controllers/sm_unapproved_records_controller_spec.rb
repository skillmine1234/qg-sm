require 'spec_helper'

describe SmUnapprovedRecordsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all sm_unapproved_records as @sm_unapproved_records" do
      sm_unapproved_record = Factory(:sm_unapproved_record, :sm_approvable_type => 'SmBank')
      get :index
      assigns(:records).should eq([{:record_type=>"SmBank", :record_count=>1}, {:record_type=>"SmBankAccount", :record_count=>0}])
    end
  end
end