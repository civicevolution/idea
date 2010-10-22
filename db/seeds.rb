# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
# latest version 

# get specific data from table
# file = File.open('dump.yml','w')
# file.puts YAML::dump(TeamRegistration.find_by_member_id_and_team_id(1,10000))
# file.close

require 'active_record/fixtures'

puts "create_fixture for admin_groups, admin_privileges, admins"

Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "admins")
Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "admin_groups")
Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "admin_privileges")


#puts "create_fixture for item_types & member, team, item, team_registration"

#Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "item_types")
#Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "items")
#Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "teams")
#Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "members")
#Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "team_registrations")

#Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "pages")
