require 'pivotal-tracker'
require 'terminal-table/import'
require 'pp'

API_TOKEN = ENV['PIVOTAL_API_TOKEN']

raise "Env Variable PIVOTAL_API_TOKEN must be defined." unless ENV.key? 'PIVOTAL_API_TOKEN' 

def get_project(name)
  matching_projects = PivotalTracker::Project.all.select { |project| project.name.downcase.include? name.downcase }
  return matching_projects[0]
end


def print_wip(project_name)
  PivotalTracker::Client.token = API_TOKEN
  PivotalTracker::Client.use_ssl = true
  output = table(['email', 'Open Stories'])
  project = get_project project_name
  puts project.name
  members = project.memberships.all
  members.each do |member|
    num_assigned_stories = project.stories.all(:mywork => member.initials, :state => "started,finished,delivered,rejected").count
    output << [member.email,  num_assigned_stories] unless num_assigned_stories == 0
  end
  puts output
  puts
end

ARGV.each { |x| print_wip x }
