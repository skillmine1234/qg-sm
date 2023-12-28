class AddAttemptNoToPendingSmPayments < ActiveRecord::Migration
  def change
    add_column :pending_sm_payments, :attempt_no, :integer, comment: 'the attempt number of the requery'         
  end
end
