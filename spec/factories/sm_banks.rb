# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sm_bank do
    sequence(:code) {|n| "%04i" % "#{n}"}
    name "Foo"
    bank_code "ABCD0XYZABC"
    low_balance_alert_at 0
    identity_user_id { Factory(:iam_cust_user, approval_status: 'A').username }
    neft_allowed "N"
    imps_allowed "N"
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    lock_version 1
    approval_status "U"
    last_action "C"
    approved_version 1
    is_enabled "Y"
  end
end