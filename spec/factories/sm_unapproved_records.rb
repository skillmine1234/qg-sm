# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sm_unapproved_record do
    sm_approvable_id 1
    sm_approvable_type "MyString"
  end
end
