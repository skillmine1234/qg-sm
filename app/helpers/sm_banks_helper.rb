module SmBanksHelper
  def find_sm_banks(params)
    sm_banks = (params[:approval_status].present? and params[:approval_status] == 'U') ? SmBank.unscoped : SmBank
    sm_banks = sm_banks.where("code IN (?)", params[:code].split(",").collect(&:strip)) if params[:code].present?
    sm_banks = sm_banks.where("is_enabled=?",params[:is_enabled]) if params[:is_enabled].present?
    sm_banks = sm_banks.where("name IN (?)", params[:name].split(",").collect(&:strip)) if params[:name].present?
    sm_banks = sm_banks.where("bank_code IN (?)", params[:bank_code].split(",").collect(&:strip)) if params[:bank_code].present?
    sm_banks
  end
end
