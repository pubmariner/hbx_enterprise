require 'net/http'
require 'pry'


dir_path = "" # Location of CVs. e.g. /Users/Downloads/brokers_with_office_locations/
url_string = "" # REST URL where the project is running e.g. http://localhost:3004/brokers/legacy_xml

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