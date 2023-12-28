# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sm_bank_account do
    sequence(:sm_code) {|n| "AB"+ "%03i" % "#{n}"}
    sequence(:customer_id) {|n| "9" + "%03i" % "#{n}" }
    sequence(:account_no) {|n| "6" + "%09i" % "#{n}" }
    mmid "1234534"
    mobile_no "1234567899"
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    lock_version 1
    approval_status "U"
    last_action "C"
    approved_version 1
    is_enabled "Y"
  end
end