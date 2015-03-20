require 'factory_girl'

FactoryGirl.define do
  
  factory :alt do
    alt "A description of the image"
    dynamic_image
  end
  
  factory :equation do
    element "a + b = 3"
    dynamic_image
  end

  factory :user do 
    transient do
      demo_library Library.new(:id => 2, :name => 'Demo')
      describer_role Role.new(:id => 3, :name => 'Describer')
    end
    
    sequence(:email) {|n| 'somebody#{n}@example.com'}
    sequence(:username) {|n| "User-#{n}"}
    first_name "John"
    last_name "Smith"
    password '123456'
    libraries { [ demo_library ]}
    roles { [ describer_role ]}
    after(:build) do |user, evaluator|
      # Wire up has_many using the current user and defined role and library
      user.user_libraries = [ UserLibrary.new(:user => user, :library => evaluator.demo_library) ]
      user.user_roles = [ UserRole.new(:user => user, :role => Role.new(:id => 3)) ]
    end
  end

  factory :user_role do
    user
    role { Role.new(:id => 3) }
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

  factory :user_library do
    user
    library
  end

  factory :dynamic_image do
    image_location 'images/first.jpg'
    book
  end

  factory :dynamic_description do
    body 'sample description'
    is_current 1
    association :submitter, factory: :user
  end

end