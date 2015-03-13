class RepubCv

  def self.nses
    {
      :cv => "http://openhbx.org/api/terms/1.0"
    }
  end

  def self.template(node)
    <<-XMLCODE
<?xml version='1.0'?>
<enrollment xmlns="http://openhbx.org/api/terms/1.0">
#{node.canonicalize}
</enrollment>
XMLCODE
  end

  def self.create_nodes(xml)
    nodes = {}
    xml.xpath("//cv:policy", nses).each do |node|
      ct = (node.at_xpath("cv:enrollment/cv:plan/cv:coverage_type", nses).content.split("#").last.downcase == "medical") ? "H" : "D"
      nodes[ct] = template(node)
    end
    nodes
  end

  def self.run
    dir_glob = Dir.glob(File.join(File.dirname(__FILE__), "system_cvs", "*.xml"))
    dir_glob.each do |f|
      bn = File.basename(f).split(".").first
      in_file = File.open(f)
      xml = Nokogiri::XML(in_file.read)
      nodes = create_nodes(xml)
      nodes.each_pair do |k, v|
        o_file = File.join(File.dirname(__FILE__), "policy_cvs", "#{bn}_#{k}.xml")
        out_f = File.open(o_file, 'w')
        out_f.puts(v)
        out_f.close
      end
      payload = in_file.read
    end
  end

end

RepubCv.run
