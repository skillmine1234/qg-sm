class AddColumnRtgsAllowedToSmBanksTable < ActiveRecord::Migration
  def change
    add_column :sm_banks, :rtgs_allowed, :string, limit: 1, default: 'N', :null => false, :comment => "the flag to indicate if RTGS is allowed"
  end
end
