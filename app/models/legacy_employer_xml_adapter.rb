class LegacyEmployerXmlAdapter
  include Padrino::Rendering
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::OutputHelpers

  attr_reader :employer_digest

  XML_HEADER = <<-XMLCODE
<?xml version='1.0' encoding='utf-8'?>
<employers xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns1="http://dchealthlink.com/vocabulary/20131030/employer" xmlns="http://dchealthlink.com/vocabulary/20131030/employer">
XMLCODE

  XML_TRAILER = <<-XMLCODE
</employers>
XMLCODE

  XML_NS = {:cv => "http://openhbx.org/api/terms/1.0" }

  def initialize(digest)
    @employer_digest = Nokogiri::XML(digest)
    @carrier_output = Hash.new { |h, k| h[k] = initialize_new_output }
    @renderer = HbxEnterprise::App.prototype.helpers
  end

  def initialize_new_output
    xml_io = StringIO.new
    xml_io << XML_HEADER
    xml_io
  end

  def with_organization_strings
    employer_digest.xpath("//cv:employer_event/cv:body/cv:organization", XML_NS).each do |node|
      yield node.canonicalize
    end
  end

  def create_output
    with_organization_strings do |organization_string|
      render_v1_xml_for(organization_string)
    end
    @carrier_output.each_pair do |k, v|
       v << XML_TRAILER
       yield [k, v]
    end
  end

  protected

  def render_v1_xml_for(organization_string)
    @cv_hash = Parsers::Xml::Cv::OrganizationParser.parse(organization_string).to_hash

    @plan_year = latest_plan_year(@cv_hash[:employer_profile][:plan_years])

    @carriers = @plan_year[:elected_plans].map do |plan| plan[:carrier][:name] end.uniq

    if @plan_year
      @carriers.each do |carrier|
        @carrier = carrier
        group_xml = @renderer.partial "employers/legacy_v1", :locals => { :plan_year => @plan_year, :cv_hash => @cv_hash, :carrier => carrier}, :engine => :haml
        @carrier_output[@carrier].write(group_xml)
      end
    end
  end

  def latest_plan_year(plan_years)
    return plan_years.first if plan_years.length == 1
    plan_years.sort_by do |plan_year|
      Date.strptime(plan_year[:plan_year_start], "%Y%m%d")
    end.last
  end
end
