#!/usr/bin/env ruby

require 'rexml/document'
require 'pp'

if ARGV.length != 2
  puts "usage:"
  puts "ruby massage_id.rb [export_filename] [start_id] > [output_filename]"
  exit
end

xml_file = ARGV[0]
start_id = ARGV[1].to_i
id = start_id - 1

File.open(xml_file, 'r').each do |line|
  id += 1 if line.include? "<item>" 

	if line.include? "<link>http://thedailywh.at/post/"
    puts line.gsub(/post\/([0-9]*)</, "post/#{id}<") 
  elsif line.include? "<wp:post_id>"
    puts line.gsub(/>([0-9]*)</, ">#{id}<") 
	elsif line.include? "guid isPermaLink"
    puts line.gsub(/post\/([0-9]*)</, "post/#{id}<") 
  elsif line.include? "<wp:post_name>"
    puts line.gsub(/>([0-9]*)</, ">#{id}<") 
  else
    puts line
  end
end

puts id
