module SmBankAccountsHelper
  def find_sm_bank_accounts(params)
    sm_bank_accounts = (params[:approval_status].present? and params[:approval_status] == 'U') ? SmBankAccount.unscoped : SmBankAccount
    sm_bank_accounts = sm_bank_accounts.where("sm_code IN (?)", params[:sm_code].split(",").collect(&:strip)) if params[:sm_code].present?
    sm_bank_accounts = sm_bank_accounts.where("is_enabled=?",params[:is_enabled]) if params[:is_enabled].present?
    sm_bank_accounts = sm_bank_accounts.where("customer_id IN (?)", params[:customer_id].split(",").collect(&:strip)) if params[:customer_id].present?
    sm_bank_accounts = sm_bank_accounts.where("account_no IN (?)", params[:account_no].downcase.split(",").collect(&:strip)) if params[:account_no].present?
    sm_bank_accounts
  end

  def sm_banks_for_select
    SmBank.all.collect { |m| [m.code, m.code] }
  end
end
