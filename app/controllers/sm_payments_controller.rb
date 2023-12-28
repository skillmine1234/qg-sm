class SmPaymentsController < ApplicationController
  authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  include SmPaymentHelper

  def index
    authorize SmPayment
    if params[:advanced_search].present?
      sm_payments = find_sm_payments(params).order("id DESC")
    else
      sm_payments = SmPayment.order("id desc")
    end
    @sm_payments = sm_payments.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
  
  def show
    authorize @sm_payment = SmPayment.find(params[:id]).decorate
  end

  def steps
    authorize r = SmPayment.find(params[:id])
    @steps = SmPaymentDecorator.decorate_collection(r.audit_steps)
    render '/audit_steps/index'
  end
  
end