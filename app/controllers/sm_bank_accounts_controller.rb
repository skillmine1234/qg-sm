class SmBankAccountsController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include SmBankAccountsHelper
  
  def new
    @sm_bank_account = SmBankAccount.new
  end

  def create
    @sm_bank_account = SmBankAccount.new(params[:sm_bank_account])
    if !@sm_bank_account.valid?
      render "new"
    else
      @sm_bank_account.created_by = current_user.id
      @sm_bank_account.save!
      flash[:alert] = "Bank Account successfully #{@sm_bank_account.approved_id.nil? ? 'created' : 'updated'} and is pending for approval"
      redirect_to @sm_bank_account
    end
  end 

  def edit
    sm_bank_account = SmBankAccount.unscoped.find_by_id(params[:id])
    if sm_bank_account.approval_status == 'A' && sm_bank_account.unapproved_record.nil?
      params = (sm_bank_account.attributes).merge({:approved_id => sm_bank_account.id, :approved_version => sm_bank_account.lock_version})
      sm_bank_account = SmBankAccount.new(params)
    end
    @sm_bank_account = sm_bank_account
  end

  def update
    @sm_bank_account = SmBankAccount.unscoped.find_by_id(params[:id])
    @sm_bank_account.attributes = params[:sm_bank_account]
    if !@sm_bank_account.valid?
      render "edit"
    else
      @sm_bank_account.updated_by = current_user.id
      @sm_bank_account.save!
      flash[:alert] = 'Bank Account successfully modified and is pending for approval'
      redirect_to @sm_bank_account
    end
    rescue ActiveRecord::StaleObjectError
      @sm_bank_account.reload
      flash[:alert] = 'Someone edited the Bank Account the same time you did. Please re-apply your changes to the Bank Account'
      render "edit"
  end 

  def show
    @sm_bank_account = SmBankAccount.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      sm_bank_accounts = find_sm_bank_accounts(params).order("id desc")
    else
      sm_bank_accounts = (params[:approval_status].present? and params[:approval_status] == 'U') ? SmBankAccount.unscoped.where("approval_status =?",'U').order("id desc") : SmBankAccount.order("id desc")
    end
    @sm_bank_accounts_count = sm_bank_accounts.count
    @sm_bank_accounts = sm_bank_accounts.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @sm_bank_account = SmBankAccount.unscoped.find(params[:id]) rescue nil
    @audit = @sm_bank_account.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @sm_bank_account = SmBankAccount.unscoped.find(params[:id]) rescue nil
    SmBankAccount.transaction do
      approval = @sm_bank_account.approve
      if @sm_bank_account.save and approval.empty?
        flash[:alert] = "Bank Account record was approved successfully"
      else
        msg = approval.empty? ? @sm_bank_account.errors.full_messages : @sm_bank_account.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @sm_bank_account
  end

  private

  def sm_bank_account_params
    params.require(:sm_bank_account).permit(:sm_code, :customer_id, :account_no, :mmid, :mobile_no, 
                                            :created_by, :updated_by, :created_at, :updated_at, 
                                            :lock_version, :approval_status, :last_action, :approved_version, :approved_id,
                                            :is_enabled)
  end
end
