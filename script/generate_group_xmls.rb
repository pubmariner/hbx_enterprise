# How to Generate Group XMLs?
# Set the 'dir_path' below and in app/controllers/employer.rb
# The group xmls will be generated here. 1 xml file per carrier.
# Set the 'exchange_version' number in app/views/employers/legacy_employer.haml
# exchange_version "1" for new employers, next highest integer for renewing employers
#
# run the padrino server 'padrino s -p 3004'
# run the script 'ruby script/generate_group_xmls.rb'
#
# Groups xmls will be generated in dir_path. e.g. CareFirst.xml, Aetna.xml
# Each group xml file is expected to have only one global <employers><employers> wrapping tag.
#
# Delete the extra <employers><employers> tags
#
# e.g. I usually use a Sublime Text to replace all occurrences on
# </employers>
# <?xml version='1.0' encoding='utf-8' ?>
# <employers xmlns:ns1='http://dchealthlink.com/vocabulary/20131030/employer' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns='http://dchealthlink.com/vocabulary/20131030/employer'>
# with empty string
# This leaves only the wrapping <employers><employers> tags

require 'net/http'
require 'pry'

dir_path = "" # Location of CVs. e.g. /Users/Downloads/employers_0321/
url_string = "" # REST URL where the project is running e.g. http://localhost:3004/employers/legacy_xml

def post_xml url_string, xml_string
  uri = URI.parse url_string
  request = Net::HTTP::Post.new uri.path
  request.body = xml_string
  request.content_type = 'text/xml'
  response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
  response.body
end

Dir.glob("#{dir_path}/**/*").each do |file_path|
  xml_string = File.read(file_path)
  post_xml url_string, xml_string
end