require 'nokogiri'

class HbxEnterprise::App

XML_HEADER = <<-XMLCODE
<?xml version='1.0' encoding='utf-8' ?>
<brokers xmlns:ns1='urn:dchbx:brokerv1' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns='urn:dchbx:brokerv1' xsi:schemaLocation='urn:dchbx:broker broker_20130903.xsd'>
XMLCODE

  file_path = " "  # dir_path where broker xml that need to be generated for NFP.
  File.open(file_path, 'a') { |file| file.write(XML_HEADER); }

  carrier_br_file_path = " " # dir_path where broker xml that need to be generated for carrier's.
  File.open(carrier_br_file_path, 'a') { |file| file.write(XML_HEADER); }

  post '/brokers/legacy_xml' do
    @cv_hash = Parsers::Xml::Cv::IndividualParser.parse(request.body.read).to_hash
    broker_xml = render "brokers/legacy_broker", :locals =>{ :individual=> @cv_hash }
    File.open(file_path, 'a') { |file| file.write(broker_xml); }
    doc = Nokogiri::XML(broker_xml)

    if doc.xpath('//*[name()="ns1:broker_payment_accounts"]').present?  # removing broker_payment_accounts, broker ACH info should not be include in carrier's broker xml.
      doc.xpath('//*[name()="ns1:broker_payment_accounts"]').each do |node|
        node.remove
      end
      File.open(carrier_br_file_path, 'a') { |file| file.write(doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION, :indent => 2)); }
    end
    return
  end
end