require 'csv'
class EnrollmentFilter

  def self.process(source, target)
    src_count = 0
    tar_count = 0
    missing = 0 
    CSV.open("#{Padrino.root}/missing_enrollments.csv", "wb") do |csv|
      CSV.foreach("#{Padrino.root}/#{source}") do |source_row|
        puts src_count
        src_count += 1

        if src_count == 1
          csv << source_row
          next
        end

        next if !['3/1/2015', '03/01/2015'].include?(scrub_element(source_row[6]))
        source_elements = [source_row[11], source_row[19], source_row[21] ].map{|x| scrub_element(x) }

        tar_count = 0
        match_found = false

        CSV.foreach("#{Padrino.root}/#{target}") do |target_row|
          tar_count += 1

          next if tar_count == 1
          next if !['3/1/2015', '03/01/2015'].include?(scrub_element(target_row[6]))

          target_elements = [target_row[11], target_row[19], target_row[21] ].map{|x| scrub_element(x) }
          if target_elements == source_elements
            match_found = true
            break
          end
        end
        
        if match_found == false
          csv << source_row
          missing += 1
        end
      end
    end
  end

  def self.scrub_element(ele)
    ele.to_s.strip.scrub_utf8
  end
end