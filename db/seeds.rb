# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.delete_all
Category.delete_all
Box.delete_all
Photo.delete_all
Report.delete_all
Notification.delete_all
UserBoxFollow.delete_all
UserFollowRelationship.delete_all
Like.delete_all
Comment.delete_all

def make_users
  10.times do |n|
    name  = Faker::Name.name
    email = "user#{n+1}@gmail.com"
    password  = "123456789"
    temp = rand(31)
    source = "http://localhost:8000/#{temp}.jpg"
    image = open(source)
    u = User.create(name:     name,
                    email:    email,
                    password: password,
                    password_confirmation: password,
                    avatar: image)
    if(n< 7)
      u.verify!
    end
    if(n == 0)
      u.toggle(:admin)
    end
    u.save
  end
  puts 'make users'
end

def make_categories
  name=[ "Architecture", "Art", "Cars & Motorcycle", "Design", "DIY & Crafts", "Education",
         "Films & Musics & Books", "Fitness", "Food & Drinks", "Gardening", "Geek", "Hair & Beauty",
         "History", "Holiday", "Home Decor", "Humor", "Kids", "My Life", "Women 's Apparel", "Men 's Apparel",
         "Outdoors", "People", "Pets", "Photography", "Print & Posters", "Products", "Science & Nature",
         "Sports", "Technology", "Travel & Places", "Wedding & Events", "Others"
  ]
  i = 0
  while i < 32 do
    Category.create!(name: name[i])
    i += 1
  end
  puts 'make categories'
end

def make_boxes
  users = User.all(limit: 5)
  5.times do
    title = Faker::Company.name
    category = rand(32) + 1
    users.each { |user| user.boxes.create!(title: title, category_id: category)}
  end
  puts 'make boxes'
end

def make_relationships
  users = User.all
  user  = users.first
  followed_users = users[2..10]
  followers      = users[3..8]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
  puts 'make relationships'
end

def make_notifications
  users = User.all[3..10]
  users.each do |user|
    Notification.create!(source_id: user.id, target_id: 1, relation_type: "user_user_relationships")
  end
  liked_photo = User.first.boxes[0].photos[0]

  users.each do |user|
    Notification.create!(source_id: user.id, target_id: 1, relation_type: "user_photo_actions like #{liked_photo.id}")
  end

  puts 'make notifications'
end

def make_user_box_rel

  boxes = Box.all[1..4]
  following_box_user = User.find(3)

  boxes.each do | box |
    following_box_user.follow_box!(box)
  end

  target_box = User.first.boxes[0]
  users = User.all[3..5]
  users.each do |user|
    user.follow_box!(target_box)
  end
  puts 'make user follows'
end

def make_photos
  users = User.all(limit: 5)
  size=[
    { x: 300, y: 400 },
    { x: 500, y: 500 },
    { x: 640, y: 480 },
    { x: 300, y: 600 }
  ]
  users.each do |user|
    user.boxes.each do |b|
      5.times do
        name = Faker::PhoneNumber.phone_number
        description = Faker::Internet.domain_name
        temp = rand(31)
        source = "http://localhost:8000/#{temp}.jpg"
        image = open(source)
        if !image.is_a? StringIO
          b.photos.create(name: name, description: description, image: image)
        end
      end
    end
  end
  puts 'make photos'
end

def make_users_like_photos
  users=User.all(limit: 5)
  users.each do |u|
    50.times do
      i = rand(Photo.count -2) + 1
      photo = Photo.find_by_id(i)
      if !photo.nil?
        u.act_on_photo!(photo, :like)
      end
    end
  end
  puts'make likes'
end


#make new db
make_users
make_categories
make_boxes
make_photos
make_relationships
# make_users_like_photos

puts 'seed completed'
