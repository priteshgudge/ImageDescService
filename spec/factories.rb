require 'factory_girl'

FactoryGirl.define do
  
  factory :alt do
    alt "A description of the image"
    dynamic_image
  end

  factory :user do 
    sequence(:email) {|n| 'somebody#{n}@example.com'}
    sequence(:username) {|n| "User-#{n}"}
    first_name "John"
    last_name "Smith"
    password '123456'
    before(:create) do |user, evaluator|
      create_list(:library, 1)
      create_list(:user_role, 1)
    end
  end

  factory :role do 
    name 'Describer'
  end  
  
  factory :user_role do
    user
    role
  end
  
  factory :book do
    uid "123456"
    isbn "1234567890123"
    xml_file "foo.xml"
    library
  end
  
  factory :library do
    sequence(:name) {|n| 'Test#{n}'}
  end

  factory :user_library do |u_lib|
       u_lib.association :user
       u_lib.association :library
  end

  factory :dynamic_image do
    image_location 'images/first.jpg'
    book
  end

  factory :dynamic_description do |desc|
    desc.body 'sample description'
    desc.submitter 'testSystem'
    desc.dynamic_image_id 1
  end

end