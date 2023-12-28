class SmBanksController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include SmBanksHelper
  
  def new
    @sm_bank = SmBank.new
  end

  def create
    @sm_bank = SmBank.new(params[:sm_bank])
    if !@sm_bank.valid?
      render "new"
    else
      @sm_bank.created_by = current_user.id
      @sm_bank.save!
      flash[:alert] = "Bank successfully #{@sm_bank.approved_id.nil? ? 'created' : 'updated'} and is pending for approval"
      redirect_to @sm_bank
    end
  end 

  def edit
    sm_bank = SmBank.unscoped.find_by_id(params[:id])
    if sm_bank.approval_status == 'A' && sm_bank.unapproved_record.nil?
      params = (sm_bank.attributes).merge({:approved_id => sm_bank.id, :approved_version => sm_bank.lock_version})
      sm_bank = SmBank.new(params)
    end
    @sm_bank = sm_bank
  end

  def update
    @sm_bank = SmBank.unscoped.find_by_id(params[:id])
    @sm_bank.attributes = params[:sm_bank]
    if !@sm_bank.valid?
      render "edit"
    else
      @sm_bank.updated_by = current_user.id
      @sm_bank.save!
      flash[:alert] = 'Bank successfully modified and is pending for approval'
      redirect_to @sm_bank
    end
    rescue ActiveRecord::StaleObjectError
      @sm_bank.reload
      flash[:alert] = 'Someone edited the Bank the same time you did. Please re-apply your changes to the Bank'
      render "edit"
  end 

  def show
    @sm_bank = SmBank.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      sm_banks = find_sm_banks(params).order("id desc")
    else
      sm_banks = (params[:approval_status].present? and params[:approval_status] == 'U') ? SmBank.unscoped.where("approval_status =?",'U').order("id desc") : SmBank.order("id desc")
    end
    @sm_banks_count = sm_banks.count
    @sm_banks = sm_banks.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @sm_bank = SmBank.unscoped.find(params[:id]) rescue nil
    @audit = @sm_bank.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    @sm_bank = SmBank.unscoped.find(params[:id]) rescue nil
    SmBank.transaction do
      approval = @sm_bank.approve
      if @sm_bank.save and approval.empty?
        flash[:alert] = "Bank record was approved successfully"
      else
        msg = approval.empty? ? @sm_bank.errors.full_messages : @sm_bank.errors.full_messages << approval
        flash[:alert] = msg
        raise ActiveRecord::Rollback
      end
    end
    redirect_to @sm_bank
  end

  def resend_notification
    @sm_bank = SmBank.find(params[:id]) rescue nil
    flash[:alert] = @sm_bank.resend_setup
    redirect_to @sm_bank
  end

  private

  def sm_bank_params
    params.require(:sm_bank).permit(:code, :name, :bank_code, :low_balance_alert_at, :identity_user_id, :neft_allowed, :imps_allowed, :rtgs_allowed, :is_enabled,  
                                    :created_by, :updated_by, :created_at, :updated_at, 
                                    :lock_version, :approval_status, :last_action, :approved_version, :approved_id, :notification_sent_at)
  end
end
