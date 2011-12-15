require 'pivotal-tracker'
require 'terminal-table/import'
require 'pp'

raise "Env Variable PIVOTAL_API_TOKEN must be defined." unless ENV.key? 'PIVOTAL_API_TOKEN' 

API_TOKEN = ENV['PIVOTAL_API_TOKEN']
PivotalTracker::Client.token = API_TOKEN
PivotalTracker::Client.use_ssl = true

def get_all_projects
  PivotalTracker::Project.all
end

def find_project_by_name(project_name)
  matching_projects = PivotalTracker::Project.all.select { |project| project.name.downcase.include? name.downcase }
  return matching_projects[0]
end

def print_wip(project)
  output = table(['email', 'Open Stories'])
  members = project.memberships.all
  members.each do |member|
    num_assigned_stories = project.stories.all(:mywork => member.initials, :state => "started,finished,delivered,rejected").count
    output << [member.email,  num_assigned_stories] unless num_assigned_stories == 0
  end

  puts project.name
  puts output
  puts
end

get_all_projects.each do |project| 
  print_wip project rescue puts "Unable to Calculate WIP for #{project.name}"
end
