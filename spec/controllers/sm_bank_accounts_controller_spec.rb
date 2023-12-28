require 'spec_helper'

describe SmBankAccountsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
    
    mock_ldap
  end

  describe "GET index" do
    it "assigns all sm_bank_accounts as @sm_bank_accounts" do
      sm_bank = Factory(:sm_bank, :code => "ABC1410", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      get :index
      assigns(:sm_bank_accounts).should eq([sm_bank_account])
    end

    it "assigns all unapproved sm_bank_accounts as @sm_bank_accounts when approval_status is passed" do
      sm_bank = Factory(:sm_bank, :code => "ABC1411", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:sm_bank_accounts).should eq([sm_bank_account])
    end
  end

  describe "GET show" do
    it "assigns the requested sm_bank_account as @sm_bank_account" do
      sm_bank = Factory(:sm_bank, :code => "ABC1412", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      get :show, {:id => sm_bank_account.id}
      assigns(:sm_bank_account).should eq(sm_bank_account)
    end
  end

  describe "GET new" do
    it "assigns a new sm_bank_account as @sm_bank_account" do
      get :new
      assigns(:sm_bank_account).should be_a_new(SmBankAccount)
    end
  end

  describe "GET edit" do
    it "assigns the requested sm_bank_account with status 'U' as @sm_bank_account" do
      sm_bank = Factory(:sm_bank, :code => "ABC1413", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'U')
      get :edit, {:id => sm_bank_account.id}
      assigns(:sm_bank_account).should eq(sm_bank_account)
    end

    it "assigns the requested sm_bank_account with status 'A' as @sm_bank_account" do
      sm_bank = Factory(:sm_bank, :code => "ABC1414", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      get :edit, {:id => sm_bank_account.id}
      assigns(:sm_bank_account).should eq(sm_bank_account)
    end

    it "assigns the new sm_bank_account with requested sm_bank_account params when status 'A' as @sm_bank_account" do
      sm_bank = Factory(:sm_bank, :code => "ABC1415", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      params = (sm_bank_account.attributes).merge({:approved_id => sm_bank_account.id,:approved_version => sm_bank_account.lock_version})
      get :edit, {:id => sm_bank_account.id}
      assigns(:sm_bank_account).should eq(SmBankAccount.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1416", :approval_status => 'A')
        params = Factory.attributes_for(:sm_bank_account, :sm_code => sm_bank.code)
        expect {
          post :create, {:sm_bank_account => params}
        }.to change(SmBankAccount.unscoped, :count).by(1)
        flash[:alert].should  match(/Bank Account successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sm_bank_account as @sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1417", :approval_status => 'A')
        params = Factory.attributes_for(:sm_bank_account, :sm_code => sm_bank.code)
        post :create, {:sm_bank_account => params}
        assigns(:sm_bank_account).should be_a(SmBankAccount)
        assigns(:sm_bank_account).should be_persisted
      end

      it "redirects to the created sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1418", :approval_status => 'A')
        params = Factory.attributes_for(:sm_bank_account, :sm_code => sm_bank.code)
        post :create, {:sm_bank_account => params}
        response.should redirect_to(SmBankAccount.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sm_bank_account as @sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1419", :approval_status => 'A')
        params = Factory.attributes_for(:sm_bank_account, :sm_code => sm_bank.code)
        params[:sm_code] = nil
        expect {
          post :create, {:sm_bank_account => params}
        }.to change(SmBankAccount, :count).by(0)
        assigns(:sm_bank_account).should be_a(SmBankAccount)
        assigns(:sm_bank_account).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        sm_bank = Factory(:sm_bank, :code => "ABC1420", :approval_status => 'A')
        params = Factory.attributes_for(:sm_bank_account, :sm_code => sm_bank.code)
        params[:sm_code] = nil
        post :create, {:sm_bank_account => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1421", :approval_status => 'A')
        sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :mobile_no => "1234567888")
        params = sm_bank_account.attributes.slice(*sm_bank_account.class.attribute_names)
        params[:mobile_no] = "1234568888"
        put :update, {:id => sm_bank_account.id, :sm_bank_account => params}
        sm_bank_account.reload
        sm_bank_account.mobile_no.should == "1234568888"
      end

      it "assigns the requested sm_bank_account as @sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1422", :approval_status => 'A')
        sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :mobile_no => "1234567888")
        params = sm_bank_account.attributes.slice(*sm_bank_account.class.attribute_names)
        params[:mobile_no] = "1234568888"
        put :update, {:id => sm_bank_account.to_param, :sm_bank_account => params}
        assigns(:sm_bank_account).should eq(sm_bank_account)
      end

      it "redirects to the sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1423", :approval_status => 'A')
        sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :mobile_no => "1234568888")
        params = sm_bank_account.attributes.slice(*sm_bank_account.class.attribute_names)
        params[:mobile_no] = "1234568888"
        put :update, {:id => sm_bank_account.to_param, :sm_bank_account => params}
        response.should redirect_to(sm_bank_account)
      end

      it "should raise error when tried to update at same time by many" do
        sm_bank = Factory(:sm_bank, :code => "ABC1424", :approval_status => 'A')
        sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :mobile_no => "1234568888")
        params = sm_bank_account.attributes.slice(*sm_bank_account.class.attribute_names)
        params[:mobile_no] = "1234568888"
        sm_bank_account2 = sm_bank_account
        put :update, {:id => sm_bank_account.id, :sm_bank_account => params}
        sm_bank_account.reload
        sm_bank_account.mobile_no.should == "1234568888"
        params[:mobile_no] = "1234588888"
        put :update, {:id => sm_bank_account2.id, :sm_bank_account => params}
        sm_bank_account.reload
        sm_bank_account.mobile_no.should == "1234568888"
        flash[:alert].should  match(/Someone edited the Bank Account the same time you did. Please re-apply your changes to the Bank Account/)
      end
    end

    describe "with invalid params" do
      it "assigns the sm_bank_account as @sm_bank_account" do
        sm_bank = Factory(:sm_bank, :code => "ABC1425", :approval_status => 'A')
        sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :account_no => "61112223333")
        params = sm_bank_account.attributes.slice(*sm_bank_account.class.attribute_names)
        params[:account_no] = nil
        put :update, {:id => sm_bank_account.to_param, :sm_bank_account => params}
        assigns(:sm_bank_account).should eq(sm_bank_account)
        sm_bank_account.reload
        params[:account_no] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        sm_bank = Factory(:sm_bank, :code => "ABC1426", :approval_status => 'A')
        sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
        params = sm_bank_account.attributes.slice(*sm_bank_account.class.attribute_names)
        params[:account_no] = nil
        put :update, {:id => sm_bank_account.id, :sm_bank_account => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested sm_bank_account as @sm_bank_account" do
      sm_bank = Factory(:sm_bank, :code => "ABC1427", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      get :audit_logs, {:id => sm_bank_account.id, :version_id => 0}
      assigns(:sm_bank_account).should eq(sm_bank_account)
      assigns(:audit).should eq(sm_bank_account.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:sm_bank_account).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sm_bank = Factory(:sm_bank, :code => "ABC1428", :approval_status => 'A')
      sm_bank_account1 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      sm_bank_account2 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'U', :mobile_no => "1234568888", :approved_version => sm_bank_account1.lock_version, :approved_id => sm_bank_account1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sm_bank_account1.approval_status.should == 'A'
      SmUnapprovedRecord.count.should == 1
      put :approve, {:id => sm_bank_account2.id}
      SmUnapprovedRecord.count.should == 0
      sm_bank_account1.reload
      sm_bank_account1.mobile_no.should == '1234568888'
      sm_bank_account1.updated_by.should == "666"
      SmUnapprovedRecord.find_by_id(sm_bank_account2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sm_bank = Factory(:sm_bank, :code => "ABC1429", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :mobile_no => '1234568888', :approval_status => 'U')
      SmUnapprovedRecord.count.should == 1
      put :approve, {:id => sm_bank_account.id}
      SmUnapprovedRecord.count.should == 0
      sm_bank_account.reload
      sm_bank_account.mobile_no.should == '1234568888'
      sm_bank_account.approval_status.should == 'A'
    end
  end
end
