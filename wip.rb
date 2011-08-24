require 'pivotal-tracker'
require 'pp'

API_TOKEN = ENV['PIVOTAL_API_TOKEN']

if ARGV.length != 1
  puts "usage:"
  puts "ruby wip.rb [project_name or substring]"
  exit
end

raise "Env Variable PIVOTAL_API_TOKEN must be defined." unless ENV.key? 'PIVOTAL_API_TOKEN' 

def get_project(name)
  matching_projects = PivotalTracker::Project.all.select { |project| project.name.downcase.include? name.downcase }
  return matching_projects[0]
end

PivotalTracker::Client.token = API_TOKEN
project = get_project ARGV[0]
puts project.name
members = project.memberships.all
members.each do |member|
  num_assigned_stories = project.stories.all(:mywork => member.initials).count
  puts "#{member.email}: #{num_assigned_stories}" unless num_assigned_stories == 0
end
