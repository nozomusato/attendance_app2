User.create!(name:  "管理者",
             email: "email@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number: 101,
             uid: "101",
             admin: true)
             
User.create!(name:  "上長A",
             email: "supervisor1@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number: 102,
             uid: "102",
             superior: true)
             
User.create!(name:  "上長B",
             email: "superior2@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number: 103,
             uid: "103",
             superior: true)

59.times do |n|
  name  = Faker::Name.name
  email = "email#{n+1}@sample.com"
  password = "password"
  employee_number = "#{n+1}"
  uid = "#{n+1}"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               employee_number: employee_number,
               uid: uid)
end