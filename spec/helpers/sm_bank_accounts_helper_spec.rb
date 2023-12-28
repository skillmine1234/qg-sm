require 'spec_helper'

describe SmBankAccountsHelper do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context "find_sm_bank_accounts" do
    it "should find sm_bank_accounts" do
      sm_bank1 = Factory(:sm_bank, :code => "AAA1310", :approval_status => 'A')
      sm_bank_account1 = Factory(:sm_bank_account, :sm_code => sm_bank1.code, :approval_status => "A")
      find_sm_bank_accounts({:sm_code => 'AAA1310'}).should == [sm_bank_account1]
      find_sm_bank_accounts({:sm_code => 'AAA1311'}).should == []
      find_sm_bank_accounts({:sm_code => 'AAB1310'}).should == []
      find_sm_bank_accounts({:sm_code => 'AAA 1310'}).should == []
      find_sm_bank_accounts({:sm_code => 'AAA'}).should == []

      sm_bank2 = Factory(:sm_bank, :code => "AAA1311", :approval_status => 'A')
      sm_bank_account2 = Factory(:sm_bank_account, :sm_code => sm_bank1.code, :is_enabled => "Y", :approval_status => 'A')
      find_sm_bank_accounts({:is_enabled => "Y"}).should == [sm_bank_account1, sm_bank_account2]
      find_sm_bank_accounts({:is_enabled => "N"}).should == [] 

      sm_bank3 = Factory(:sm_bank, :code => "AAA1312", :approval_status => 'A')
      sm_bank_account3 = Factory(:sm_bank_account, :sm_code => sm_bank3.code, :customer_id => '9876', :approval_status => "A")
      find_sm_bank_accounts({:customer_id => '9876'}).should == [sm_bank_account3]
      find_sm_bank_accounts({:customer_id => '987'}).should == []
      find_sm_bank_accounts({:customer_id => '98765'}).should == []

      sm_bank4 = Factory(:sm_bank, :code => "AAA1314", :approval_status => 'A')
      sm_bank_account4 = Factory(:sm_bank_account, :sm_code => sm_bank4.code, :account_no => '155671235', :approval_status => "A")
      find_sm_bank_accounts({:account_no => '155671235'}).should == [sm_bank_account4]
      find_sm_bank_accounts({:account_no => '15567123'}).should == []
    end
  end

  context "sm_banks_for_select" do
    it "should return all approved sm_banks records" do
      sm_bank1 = Factory(:sm_bank, :code => "AAA1315", :approval_status => 'A')
      sm_bank2 = Factory(:sm_bank, :code => "AAA1316", :approval_status => 'A')
      sm_bank3 = Factory(:sm_bank, :code => "AAA1317", :approval_status => 'A')
      sm_bank4 = Factory(:sm_bank, :code => "AAA1318")
      expect(sm_banks_for_select).to eq([["AAA1315", "AAA1315"], ["AAA1316", "AAA1316"], ["AAA1317", "AAA1317"]])
    end
  end
end
