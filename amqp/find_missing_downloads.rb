dir_glob = Dir.glob(File.join(File.dirname(__FILE__), "system_cvs", "*.xml"))
st_ids = []
dir_glob.each do |f|
  st = File.basename(f).split(".").first
  st_ids << st
end

edi_file = File.open(File.join(File.dirname(__FILE__), "enrollment_lists", "original_system_enrollment_list.txt"))

edi_ids = edi_file.read.split("\n").map do |line|
  line.strip
end

edi_file.close

(edi_ids - st_ids).each do |eid|
  puts eid
end
