require 'spec_helper'

describe SmBanksController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
    
    mock_ldap
  end

  describe "GET index" do
    it "assigns all sm_banks as @sm_banks" do
      sm_bank = Factory(:sm_bank, :approval_status => 'A')
      get :index
      assigns(:sm_banks).should eq([sm_bank])
    end

    it "assigns all unapproved sm_banks as @sm_banks when approval_status is passed" do
      sm_bank = Factory(:sm_bank, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:sm_banks).should eq([sm_bank])
    end
  end

  describe "GET show" do
    it "assigns the requested sm_bank as @sm_bank" do
      sm_bank = Factory(:sm_bank)
      get :show, {:id => sm_bank.id}
      assigns(:sm_bank).should eq(sm_bank)
    end
  end

  describe "GET new" do
    it "assigns a new sm_bank as @sm_bank" do
      get :new
      assigns(:sm_bank).should be_a_new(SmBank)
    end
  end

  describe "GET edit" do
    it "assigns the requested sm_bank with status 'U' as @sm_bank" do
      sm_bank = Factory(:sm_bank, :approval_status => 'U')
      get :edit, {:id => sm_bank.id}
      assigns(:sm_bank).should eq(sm_bank)
    end

    it "assigns the requested sm_bank with status 'A' as @sm_bank" do
      sm_bank = Factory(:sm_bank,:approval_status => 'A')
      get :edit, {:id => sm_bank.id}
      assigns(:sm_bank).should eq(sm_bank)
    end

    it "assigns the new sm_bank with requested sm_bank params when status 'A' as @sm_bank" do
      sm_bank = Factory(:sm_bank,:approval_status => 'A')
      params = (sm_bank.attributes).merge({:approved_id => sm_bank.id,:approved_version => sm_bank.lock_version})
      get :edit, {:id => sm_bank.id}
      assigns(:sm_bank).should eq(SmBank.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new sm_bank" do
        params = Factory.attributes_for(:sm_bank)
        expect {
          post :create, {:sm_bank => params}
        }.to change(SmBank.unscoped, :count).by(1)
        flash[:alert].should  match(/Bank successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sm_bank as @sm_bank" do
        params = Factory.attributes_for(:sm_bank)
        post :create, {:sm_bank => params}
        assigns(:sm_bank).should be_a(SmBank)
        assigns(:sm_bank).should be_persisted
      end

      it "redirects to the created sm_bank" do
        params = Factory.attributes_for(:sm_bank)
        post :create, {:sm_bank => params}
        response.should redirect_to(SmBank.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sm_bank as @sm_bank" do
        params = Factory.attributes_for(:sm_bank)
        params[:code] = nil
        expect {
          post :create, {:sm_bank => params}
        }.to change(SmBank, :count).by(0)
        assigns(:sm_bank).should be_a(SmBank)
        assigns(:sm_bank).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:sm_bank)
        params[:code] = nil
        post :create, {:sm_bank => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sm_bank" do
        sm_bank = Factory(:sm_bank, :name => "ABCD EFGH")
        params = sm_bank.attributes.slice(*sm_bank.class.attribute_names)
        params[:name] = "ABCD EFGH IJKL"
        put :update, {:id => sm_bank.id, :sm_bank => params}
        sm_bank.reload
        sm_bank.name.should == "ABCD EFGH IJKL"
      end

      it "assigns the requested sm_bank as @sm_bank" do
        sm_bank = Factory(:sm_bank, :name => "ABCD EFGH")
        params = sm_bank.attributes.slice(*sm_bank.class.attribute_names)
        params[:name] = "ABCD EFGH IJKL"
        put :update, {:id => sm_bank.to_param, :sm_bank => params}
        assigns(:sm_bank).should eq(sm_bank)
      end

      it "redirects to the sm_bank" do
        sm_bank = Factory(:sm_bank, :name => "ABCD EFGH")
        params = sm_bank.attributes.slice(*sm_bank.class.attribute_names)
        params[:name] = "ABCD EFGH IJKL"
        put :update, {:id => sm_bank.to_param, :sm_bank => params}
        response.should redirect_to(sm_bank)
      end

      it "should raise error when tried to update at same time by many" do
        sm_bank = Factory(:sm_bank, :name => "ABCD EFGH")
        params = sm_bank.attributes.slice(*sm_bank.class.attribute_names)
        params[:name] = "ABCD EFGH"
        sm_bank2 = sm_bank
        put :update, {:id => sm_bank.id, :sm_bank => params}
        sm_bank.reload
        sm_bank.name.should == "ABCD EFGH"
        params[:name] = "ABCD EFGH IJKL2"
        put :update, {:id => sm_bank2.id, :sm_bank => params}
        sm_bank.reload
        sm_bank.name.should == "ABCD EFGH"
        flash[:alert].should  match(/Someone edited the Bank the same time you did. Please re-apply your changes to the Bank/)
      end
    end

    describe "with invalid params" do
      it "assigns the sm_bank as @sm_bank" do
        sm_bank = Factory(:sm_bank, :name => "ABCD EFGH")
        params = sm_bank.attributes.slice(*sm_bank.class.attribute_names)
        params[:name] = nil
        put :update, {:id => sm_bank.to_param, :sm_bank => params}
        assigns(:sm_bank).should eq(sm_bank)
        sm_bank.reload
        params[:name] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        sm_bank = Factory(:sm_bank)
        params = sm_bank.attributes.slice(*sm_bank.class.attribute_names)
        params[:name] = nil
        put :update, {:id => sm_bank.id, :sm_bank => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested sm_bank as @sm_bank" do
      sm_bank = Factory(:sm_bank)
      get :audit_logs, {:id => sm_bank.id, :version_id => 0}
      assigns(:sm_bank).should eq(sm_bank)
      assigns(:audit).should eq(sm_bank.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:sm_bank).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sm_bank1 = Factory(:sm_bank, :approval_status => 'A')
      sm_bank2 = Factory(:sm_bank, :approval_status => 'U', :name => 'ABCD EFGH', :approved_version => sm_bank1.lock_version, :approved_id => sm_bank1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sm_bank1.approval_status.should == 'A'
      SmUnapprovedRecord.count.should == 1
      put :approve, {:id => sm_bank2.id}
      SmUnapprovedRecord.count.should == 0
      sm_bank1.reload
      sm_bank1.name.should == 'ABCD EFGH'
      sm_bank1.updated_by.should == "666"
      SmUnapprovedRecord.find_by_id(sm_bank2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sm_bank = Factory(:sm_bank, :name => 'ABCD EFGH', :approval_status => 'U')
      SmUnapprovedRecord.count.should == 1
      put :approve, {:id => sm_bank.id}
      SmUnapprovedRecord.count.should == 0
      sm_bank.reload
      sm_bank.name.should == 'ABCD EFGH'
      sm_bank.approval_status.should == 'A'
    end
  end
end
