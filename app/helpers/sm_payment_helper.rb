module SmPaymentHelper
  def find_sm_payments(params)
    sm_payments = SmPayment
    sm_payments = sm_payments.where("req_no IN (?)", params[:req_no].split(",").collect(&:strip)) if params[:req_no].present?
    sm_payments = sm_payments.where("customer_id IN (?)", params[:customer_id].split(",").collect(&:strip)) if params[:customer_id].present?
    sm_payments = sm_payments.where("status_code = ?", params[:status_code]) if params[:status_code].present?
    sm_payments = sm_payments.where("transfer_type = ?", params[:transfer_type]) if params[:transfer_type].present?
    sm_payments = sm_payments.where("partner_code IN (?)", params[:partner_code].split(",").collect(&:strip)) if params[:partner_code].present?
    sm_payments = sm_payments.where("debit_account_no IN (?)", params[:debit_account_no].split(",").collect(&:strip)) if params[:debit_account_no].present?
    sm_payments = sm_payments.where("rmtr_account_no IN (?)", params[:rmtr_account_no].split(",").collect(&:strip)) if params[:rmtr_account_no].present?
    sm_payments = sm_payments.where("rmtr_account_ifsc IN (?)", params[:rmtr_account_ifsc].split(",").collect(&:strip)) if params[:rmtr_account_ifsc].present?
    sm_payments = sm_payments.where("bene_account_no IN (?)", params[:bene_account_no].split(",").collect(&:strip)) if params[:bene_account_no].present?
    sm_payments = sm_payments.where("bank_ref_no IN (?)", params[:bank_ref_no].split(",").collect(&:strip)) if params[:bank_ref_no].present?
    sm_payments = sm_payments.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_req_timestamp]).beginning_of_day,Time.zone.parse(params[:to_req_timestamp]).end_of_day) if params[:from_req_timestamp].present? and params[:to_req_timestamp].present?
    sm_payments = sm_payments.where("rep_timestamp>=? and rep_timestamp<=?",Time.zone.parse(params[:from_rep_timestamp]).beginning_of_day,Time.zone.parse(params[:to_rep_timestamp]).end_of_day) if params[:from_rep_timestamp].present? and params[:to_rep_timestamp].present?
    sm_payments
  end
end