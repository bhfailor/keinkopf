# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mlp_query do
    session "MyString"
    class_start "2013-11-22 20:11:10"
    class_stop "2013-11-22 20:11:10"
    semester "MyString"
    section 1
    instructor_login_email "MyString"
    instructor_password "MyString"
  end
end
