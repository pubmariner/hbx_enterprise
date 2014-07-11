module Parsers
  module Edi
    module Etf

      ParsedAddress = Struct.new(:street1, :street2, :city, :state, :zip)

      class PersonParser
        attr_accessor :address
        def initialize(l2000, emp_id = nil)
          @person_loop = l2000
          @employer_id = emp_id
        end

        def parse_member_id
          @member_id = (@person_loop["REFs"].detect do |r|
            r[1] == "17"
          end)[2]
        end

        def parse_address
          info_loop = @person_loop["L2100A"]
          if !info_loop["N3"].blank?
            @address = ParsedAddress.new(get_street1, get_street2, get_city, get_state, get_zip)
          end
        end

        def get_street2
          street2 = nil
          info_loop = @person_loop["L2100A"]
          if !info_loop["N3"][2].blank?
            street2 = info_loop["N3"][2]
          end
          street2
        end

        def get_street1
          PersonLoop.new(@person_loop).street1
        end

        def get_city
          PersonLoop.new(@person_loop).city
        end

        def get_state
          PersonLoop.new(@person_loop).state
        end

        def get_zip
          @person_loop["L2100A"]["N4"][3]
        end

        def parse_contact
          contact_seg = @person_loop["L2100A"]["PER"]
          if !contact_seg.blank?
            if contact_seg[3]
              interpret_contact_info(contact_seg[3], contact_seg[4])
            end
            if contact_seg[5]
              interpret_contact_info(contact_seg[5], contact_seg[6])
            end
            if contact_seg[7]
              interpret_contact_info(contact_seg[7], contact_seg[8])
            end
          end
        end

        def interpret_contact_info(con_kind, con_val)
          if con_kind == "TE"
            @phone = con_val
          elsif con_kind == "EM"
            @email = con_val
          end
        end

        def parse_name
          name_loop = @person_loop["L2100A"]["NM1"]
          @name_first = name_loop[4]
          @name_last = name_loop[3]
          if !name_loop[5].blank?
            @name_middle = name_loop[5]
          end
          if !name_loop[6].blank?
            @name_pfx = name_loop[6]
          end
          if !name_loop[7].blank?
            @name_sfx = name_loop[7]
          end
          if !name_loop[9].blank?
            if name_loop[9].length > 8
              @ssn = name_loop[9]
            end
          end
        end

        def parse_demo
          demo_loop = @person_loop["L2100A"]["DMG"]
          @gender = demo_loop[3]
          if demo_loop[3].blank?
            raise demo_loop.inspect
          end
          @dob = demo_loop[2]
        end

        def generate_member
          new_member = Member.new
          new_member.gender = map_gender_code
          new_member.hbx_member_id = @member_id
          unless @dob.blank?
            new_member.dob = @dob
          end
          unless @ssn.blank?
            new_member.ssn = @ssn
          end
          new_member.import_source = "b2b_gateway"
          new_member.imported_at = Time.now
          new_member
        end

        def persist!
          new_person = check_for_person
          new_member = generate_member
          new_person.name_pfx = @name_prefix
          new_person.name_first = @name_first
          new_person.name_middle = @name_middle
          new_person.name_last = @name_last
          new_person.name_sfx = @name_suffix
          new_person.merge_member(new_member)
          unless @address.blank?
              new_address = Address.new(
                :address_type => "home",
                :address_1 => @address.street1,
                :address_2 => @address.street2,
                :city => @address.city,
                :state => @address.state,
                :zip => @address.zip
              )
              if new_address.valid?
                new_person.send(merge_method(:address), new_address)
              end
          end
          unless @email.blank?
            new_email = Email.new(
              :email_type => "home",
              :email_address => @email.downcase
            )
            new_person.merge_email(new_email)
            new_person.send(merge_method(:email), new_email)
          end
          unless @phone.blank?
            new_phone = Phone.new(
              :phone_type => "home",
              :phone_number => @phone
            )
            new_person.send(merge_method(:phone), new_phone)
          end
          if subscriber?
            if !@employer_id.blank?
              employer = Employer.find(@employer_id)
              employer.employees << new_person
              employer.save
            end
          end 
          begin
            new_person.initialize_name_full
            new_person.invalidate_find_caches
            new_person.unsafe_save!
          rescue
            raise(new_person.errors.inspect)
          end
        end

        def parse_employment_status
          @person_loop["INS"][8]
        end

        def check_for_person
          found_by_m_id_person = Person.find_for_member_id(@member_id)
          return(found_by_m_id_person) if !found_by_m_id_person.nil?
          if !@ssn.blank?
            found_by_m_ssn_person = Person.match_for_ssn(@ssn, @name_first, @name_last, @dob)
            return(found_by_m_ssn_person) if !found_by_m_ssn_person.nil?
          end
          Person.new
        end

        def self.parse_and_persist(p_loop, employer_id = nil)
          @person_parser = PersonParser.new(p_loop, employer_id)
          @person_parser.parse_all
          @person_parser.persist!
        end

        def parse_all
          @change_type = determine_change_type(@person_loop)
          parse_member_id
          parse_name
          parse_address
          parse_contact
          parse_demo
        end

        private

        def subscriber?
          @person_loop["INS"][2]== "18"
        end

        def map_gender_code
          gender_codes = {
            "M" => "male",
            "F" => "female"
          }
          result = gender_codes[@gender.strip]
          result.nil? ? "unknown" : result
        end

        def determine_change_type(l2000)
          case l2000["INS"][3]
          when "001"
            :change
          when "024"
            :stop
          else
            :add
          end
        end

        def merge_method(m_type)
#          (@change_type == "change") ? "update_#{m_type}".to_sym : "merge_#{m_type}".to_sym
          "update_#{m_type}"
        end
      end
    end
  end
end
