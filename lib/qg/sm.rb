require "qg/sm/engine"

module Qg
  module Sm
    NAME = 'Sub-Member Bank'
    GROUP = 'smb'
    MENU_ITEMS = [:sm_bank, :sm_bank_account]
    OPERATIONS = [:sm_payments]
    MODELS = ['SmUnapprovedRecord','SmBank','SmBankAccount', 'SmPayment', 'SmAuditLog', 'SmAuditStep']
    COMMON_MENU_ITEMS = [:approval_worklist]
    TEST_MENU_ITEMS = []
  end
end
