require 'spec_helper'

describe SmBanksHelper do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context "find_sm_banks" do
    it "should find sm_banks" do
      sm_bank1 = Factory(:sm_bank, :code => 'ABCD90', :approval_status => "A")
      find_sm_banks({:code => 'ABCD90'}).should == [sm_bank1]
      find_sm_banks({:code => 'Abcd 90'}).should == []

      sm_bank2 = Factory(:sm_bank, :code => "ABCD91", :is_enabled => "Y", :approval_status => 'A')
      find_sm_banks({:is_enabled => "Y"}).should == [sm_bank1, sm_bank2]
      find_sm_banks({:is_enabled => "N"}).should == [] 

      sm_bank3 = Factory(:sm_bank, :name => 'ABCD Co', :approval_status => "A")
      find_sm_banks({:name => 'ABCD Co'}).should == [sm_bank3]
      find_sm_banks({:name => 'abcdco.'}).should == []

      sm_bank4 = Factory(:sm_bank, :bank_code => 'AABB0CCCABC', :approval_status => "A")
      find_sm_banks({:bank_code => 'AABB0CCCABC'}).should == [sm_bank4]
      find_sm_banks({:bank_code => 'aabb0ccc458'}).should == []
      find_sm_banks({:bank_code => 'AABC0CCC458'}).should == []
      find_sm_banks({:bank_code => 'AABC0CCC459'}).should == []
      find_sm_banks({:bank_code => 'AABC 0CCC459'}).should == []
      find_sm_banks({:bank_code => 'AABC0CCC45'}).should == []
    end
  end  
end
