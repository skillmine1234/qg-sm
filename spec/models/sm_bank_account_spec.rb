require 'spec_helper'

describe SmBankAccount do
  include HelperMethods

  before(:each) do
    mock_ldap
  end

  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:sm_unapproved_record) }
    it { should belong_to(:sm_bank) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
  end
  
  context 'validation' do
    [:sm_code, :customer_id, :account_no, :is_enabled].each do |att|
      it { should validate_presence_of(att) }
    end

    it do 
      sm_bank = Factory(:sm_bank, :code => "AAA1201", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      should validate_uniqueness_of(:sm_code).scoped_to(:customer_id, :account_no, :approval_status)

      should validate_length_of(:sm_code).is_at_most(20) 
      should validate_length_of(:customer_id).is_at_least(3).is_at_most(15)
      should validate_length_of(:account_no).is_at_least(1).is_at_most(15)
    end

    it "should return presence validation error on mmid and mobile_no if is_mmid_and_mobile_no_mandatory? is true" do
      sm_bank = Factory(:sm_bank, :code => "AAA1215", :imps_allowed => "Y", :approval_status => 'A')
      sm_bank_account = Factory.build(:sm_bank_account, :sm_code => sm_bank.code, :mmid => nil, :mobile_no => nil)
      sm_bank_account.should_not be_valid
      sm_bank_account.errors_on(:mmid).should == ["can't be blank", "Invalid format, expected format is : {[0-9]{7}}", "is too short (minimum is 7 characters)"]
      sm_bank_account.errors_on(:mobile_no).should == ["can't be blank", "Invalid format, expected format is : {[0-9]{10}}", "is too short (minimum is 10 characters)"]
    end

    it "should not return presence validation error on mmid and mobile_no if is_mmid_and_mobile_no_mandatory? is false" do
      sm_bank = Factory(:sm_bank, :code => "AAA1216", :imps_allowed => "N", :approval_status => 'A')
      sm_bank_account = Factory.build(:sm_bank_account, :sm_code => sm_bank.code, :mmid => nil, :mobile_no => nil)
      sm_bank_account.should be_valid
      sm_bank_account.errors_on(:mmid).should == []
      sm_bank_account.errors_on(:mobile_no).should == []
    end

    it "should not return presence validation error on mmid and mobile_no if is_mmid_and_mobile_no_mandatory? is true and mmid and mobile_no not nil" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890')
      sm_bank = Factory(:sm_bank, :code => "AAA1217", :imps_allowed => "Y", :approval_status => 'A')
      sm_bank_account = Factory.build(:sm_bank_account, :sm_code => sm_bank.code, customer_id: '2345', account_no: '1234567890', :mmid => "1112223", :mobile_no => "8765432100")
      sm_bank_account.should be_valid
      sm_bank_account.errors_on(:mmid).should == []
      sm_bank_account.errors_on(:mobile_no).should == []
    end

    it "should validate length of mmid and mobile_no" do
      sm_bank = Factory(:sm_bank, :code => "AAA1217", :imps_allowed => "Y", :approval_status => 'A')
      sm_bank_account = Factory.build(:sm_bank_account, :sm_code => sm_bank.code, :mmid => "111222", :mobile_no => "876543210")
      sm_bank_account.should_not be_valid
      sm_bank_account.errors_on(:mmid).should == ["Invalid format, expected format is : {[0-9]{7}}", "is too short (minimum is 7 characters)"]
      sm_bank_account.errors_on(:mobile_no).should == ["Invalid format, expected format is : {[0-9]{10}}", "is too short (minimum is 10 characters)"]
    end

    it "should return error if sm_code is already taken" do
      sm_bank = Factory(:sm_bank, :code => "AAA1202", :approval_status => 'A')
      sm_bank_account1 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :customer_id => "9999", :account_no => "6099999901", :approval_status => 'A')
      sm_bank_account2 = Factory.build(:sm_bank_account, :sm_code => sm_bank.code, :customer_id => "9999", :account_no => "6099999901", :approval_status => 'A')
      sm_bank_account2.should_not be_valid
      sm_bank_account2.errors_on(:sm_code).should == ["has already been taken"]
    end

    it "should return error if customer_id is already present different sub member bank" do
      sm_bank1 = Factory(:sm_bank, :code => "AAA1218", :approval_status => 'A')
      sm_bank_account1 = Factory.build(:sm_bank_account, :sm_code => sm_bank1.code, :customer_id => "978740", :account_no => "001687700000012", :approval_status => 'A')
      sm_bank_account1.should be_valid
      sm_bank_account1.save.should be_true

      sm_bank2 = Factory(:sm_bank, :code => "AAA1223", :approval_status => 'A')
      sm_bank_account2 = Factory.build(:sm_bank_account, :sm_code => sm_bank2.code, :customer_id => "978740", :account_no => "001687700000013", :approval_status => 'A')
      sm_bank_account2.should_not be_valid
      sm_bank_account2.save.should_not be_true
      sm_bank_account2.errors_on(:customer_id).should == ["already exists with different sub member bank"]
    end

    it "should return error if account_no is already taken" do
      sm_bank1 = Factory(:sm_bank, :code => "AAA1219", :approval_status => 'A')
      sm_bank_account1 = Factory.build(:sm_bank_account, :sm_code => sm_bank1.code, :customer_id => "978741", :account_no => "001687700000014", :approval_status => 'A')
      sm_bank_account1.should be_valid
      sm_bank_account1.save.should be_true

      sm_bank2 = Factory(:sm_bank, :code => "AAA1220", :approval_status => 'A')
      sm_bank_account2 = Factory.build(:sm_bank_account, :sm_code => sm_bank2.code, :customer_id => "978742", :account_no => "001687700000014", :approval_status => 'A')
      sm_bank_account2.should_not be_valid
      sm_bank_account2.save.should_not be_true
      sm_bank_account2.errors_on(:account_no).should == ["has already been taken"]
    end

    it "should return error if customer_id, account_no is already taken" do
      sm_bank1 = Factory(:sm_bank, :code => "AAA1221", :approval_status => 'A')
      sm_bank_account1 = Factory.build(:sm_bank_account, :sm_code => sm_bank1.code, :customer_id => "978743", :account_no => "001687700000015", :approval_status => 'A')
      sm_bank_account1.should be_valid
      sm_bank_account1.save.should be_true

      sm_bank2 = Factory(:sm_bank, :code => "AAA1222", :approval_status => 'A')
      sm_bank_account2 = Factory.build(:sm_bank_account, :sm_code => sm_bank2.code, :customer_id => "978743", :account_no => "001687700000015", :approval_status => 'A')
      sm_bank_account2.should_not be_valid
      sm_bank_account2.save.should_not be_true
      sm_bank_account2.errors_on(:customer_id).should == ["already exists with different sub member bank"]
      sm_bank_account2.errors_on(:account_no).should == ["has already been taken"]
    end

    it "should return error if sm_code not present in bank" do
      sm_bank_account1 = Factory.build(:sm_bank_account, :sm_code => "AAA1203", :approval_status => 'A')
      sm_bank_account1.should_not be_valid
      sm_bank_account1.errors_on(:sm_code).should == ["is not present in bank"]
      sm_bank = Factory(:sm_bank, :code => "AAA1203", :approval_status => 'A')
      sm_bank_account1.sm_bank = sm_bank
      sm_bank_account1.should be_valid
    end
  end

  context "fields format" do
    it "should allow valid format" do
      sm_bank = Factory(:sm_bank, :code => "AAA1204", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')

      should allow_value(sm_bank.code).for(:sm_code)

      should allow_value('9876').for(:account_no)
      should allow_value('0123456789').for(:account_no)

      should allow_value('123').for(:customer_id)
      should allow_value('123456789098765').for(:customer_id)

      should allow_value('1234567').for(:mmid)
      should allow_value(nil).for(:mmid)

      should allow_value('9087654321').for(:mobile_no)
      should allow_value(nil).for(:mobile_no)
    end

    it "should not allow invalid format" do
      sm_bank = Factory(:sm_bank, :code => "AAA1205", :imps_allowed => "Y", :approval_status => 'A')
      sm_bank_account = Factory.build(:sm_bank_account, :sm_code => sm_bank.code, :mmid => "MMID-01", :mobile_no => "+918888665")
      sm_bank_account.save.should be_false
      sm_bank_account.errors_on(:mmid).should == ["Invalid format, expected format is : {[0-9]{7}}"]
      sm_bank_account.errors_on(:mobile_no).should == ["Invalid format, expected format is : {[0-9]{10}}"]
    end
  end
  
  context "default_scope" do 
    it "should only return 'A' records by default" do 
      sm_bank = Factory(:sm_bank, :code => "AAA1206", :approval_status => 'A')
      sm_bank_account1 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A') 
      sm_bank_account2 = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      SmBankAccount.all.should == [sm_bank_account1]
      sm_bank_account2.approval_status = 'A'
      sm_bank_account2.save
      SmBankAccount.all.should == [sm_bank_account1,sm_bank_account2]
    end
  end    

  context "sm_unapproved_records" do 
    it "oncreate: should create sm_unapproved_record if the approval_status is 'U'" do
      sm_bank = Factory(:sm_bank, :code => "AAA1207", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      sm_bank_account.reload
      sm_bank_account.sm_unapproved_record.should_not be_nil
    end

    it "oncreate: should not create sm_unapproved_record if the approval_status is 'A'" do
      sm_bank = Factory(:sm_bank, :code => "AAA1208", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      sm_bank_account.sm_unapproved_record.should be_nil
    end

    it "onupdate: should not remove sm_unapproved_record if approval_status did not change from U to A" do
      sm_bank = Factory(:sm_bank, :code => "AAA1209", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      sm_bank_account.reload
      sm_bank_account.sm_unapproved_record.should_not be_nil
      record = sm_bank_account.sm_unapproved_record
      # we are editing the U record, before it is approved
      sm_bank_account.mobile_no = 1234567888
      sm_bank_account.save
      sm_bank_account.reload
      sm_bank_account.sm_unapproved_record.should == record
    end
    
    it "onupdate: should remove sm_unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      sm_bank = Factory(:sm_bank, :code => "AAA1210", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      sm_bank_account.reload
      sm_bank_account.sm_unapproved_record.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      sm_bank_account.approval_status = 'A'
      sm_bank_account.save
      sm_bank_account.reload
      sm_bank_account.sm_unapproved_record.should be_nil
    end
    
    it "ondestroy: should remove sm_unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      sm_bank = Factory(:sm_bank, :code => "AAA1211", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code)
      sm_bank_account.reload
      sm_bank_account.sm_unapproved_record.should_not be_nil
      record = sm_bank_account.sm_unapproved_record
      # the approval process destroys the U record, for an edited record 
      sm_bank_account.destroy
      SmUnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      sm_bank = Factory(:sm_bank, :code => "AAA1212", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'U')
      sm_bank_account.approve.should == ""
      sm_bank_account.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      sm_bank = Factory(:sm_bank, :code => "AAA1213", :approval_status => 'A')
      sm_bank_account = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      sm_bank_account1 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'U', :approved_id => sm_bank_account.id, :approved_version => 6)
      sm_bank_account1.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      sm_bank = Factory(:sm_bank, :code => "AAA1214", :approval_status => 'A')
      sm_bank_account1 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'A')
      sm_bank_account2 = Factory(:sm_bank_account, :sm_code => sm_bank.code, :approval_status => 'U')
      sm_bank_account1.enable_approve_button?.should == false
      sm_bank_account2.enable_approve_button?.should == true
    end
  end
  
  context "validate_customer_with_fcr" do
    it "should allow neft for the sm_bank_account when the customer setup is complete in FCR" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      sm_bank = Factory(:sm_bank, code: '1234', neft_allowed: 'Y', imps_allowed: 'N', approval_status: 'A')
      sm_bank_account = Factory.build(:sm_bank_account, sm_code: sm_bank.code, customer_id: '2345', account_no: '1234567890')
      sm_bank_account.errors_on(:customer_id).should == []
    end

    it "should raise error when the mobile no. and email are not present in the customer setup in FCR" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: nil)
      sm_bank = Factory(:sm_bank, code: '1234', neft_allowed: 'Y', imps_allowed: 'N', approval_status: 'A')
      sm_bank_account = Factory.build(:sm_bank_account, sm_code: sm_bank.code, customer_id: '2345', account_no: '1234567890')
      sm_bank_account.errors_on(:base).should == ["Required setup for NEFT transfer not found in FCR for 2345"]
    end

    it "should raise error when there is no corresponding record in FCR" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      sm_bank = Factory(:sm_bank, code: '1234', neft_allowed: 'Y', imps_allowed: 'N', approval_status: 'A')
      sm_bank_account = Factory.build(:sm_bank_account, sm_code: sm_bank.code, customer_id: '234', account_no: '0987654321')
      sm_bank_account.errors_on(:customer_id).should == ["no record found in FCR for 234"]
    end
  end

  context "validate_account" do
    it "should allow imps for the sm_bank_account when the customer setup is complete in FCR and ATOM" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890')
      sm_bank = Factory(:sm_bank, code: '1234', neft_allowed: 'N', imps_allowed: 'Y', approval_status: 'A')
      sm_bank_account = Factory.build(:sm_bank_account, sm_code: sm_bank.code, customer_id: '2345', account_no: '1234567890')
      sm_bank_account.errors_on(:customer_id).should == []
    end

    it "should raise error when there is no corresponding record in ATOM" do
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '2222222222', ref_cust_email: 'aaa@gmail.com')
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890')
      sm_bank = Factory(:sm_bank, code: '1234', neft_allowed: 'N', imps_allowed: 'Y', approval_status: 'A')
      sm_bank_account = Factory.build(:sm_bank_account, sm_code: sm_bank.code, customer_id: '234', account_no: '0987654321')
      sm_bank_account.errors_on(:customer_id).should == ["no record found in FCR for 234"]
      sm_bank_account.errors_on(:account_no).should == ["no record found in ATOM for 0987654321"]
    end

    it "should raise error when the mobile no.s in FCR and ATOM do not match for the customer" do
      atom_customer = Factory(:atom_customer, customerid: '2345', mobileno: '2222222222', isactive: '1', accountno: '1234567890')
      fcr_customer = Factory(:fcr_customer, cod_cust_id: '2345', ref_phone_mobile: '9999000099', ref_cust_email: 'aaa@gmail.com')
      sm_bank = Factory(:sm_bank, code: '1234', neft_allowed: 'N', imps_allowed: 'Y', approval_status: 'A')
      sm_bank_account = Factory.build(:sm_bank_account, sm_code: sm_bank.code, customer_id: '2345', account_no: '1234567890')
      sm_bank_account.errors_on(:account_no).should == ["Required setup for IMPS transfer not found in ATOM for 1234567890"]
    end
  end
end