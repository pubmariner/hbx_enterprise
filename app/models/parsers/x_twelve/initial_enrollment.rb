module Parsers
  module XTwelve
    class RawBroker
      attr_accessor :name, :npn

      include EtfXpath

      def to_model
        Broker.new(
          :name_full => @name,
          :npn => @npn,
          :b_type => "broker"
        )
      end
    end

    class RawEmployer
      attr_accessor :exchange_employer_id, :name

      include EtfXpath

      def to_model
        Employer.new(
          :hbx_id => @exchange_employer_id,
          :name => @name
        )
      end
    end

    class InitialEnrollment
      attr_reader :plan, :members, :responsible_party, :carrier_id, :employer, :broker, :begin_date, :enrollment_group_id, :carrier_to_bill
      attr_reader :subscriber_id, :request_submit_timestamp

      include EtfXpath

      def self.load_file(t_type, path)
  #      begin
          InitialEnrollment.new(t_type, File.basename(path), Nokogiri::XML(File.open(path))).persist!
#        rescue Mongoid::Errors::Validations => e
 #       end
      end

      def initialize(t_type, f_name, doc)
        @file_name = f_name
        @transmission_kind = t_type
        @members = parse_members(doc)
        @responsible_party = nil
        @carrier_id = parse_carrier_id(doc)
        @enrollment_group_id = parse_enrollment_group_id(doc)
        @employer = parse_employer(doc)
        @broker = parse_broker(doc)
        @plan = RawPlan.new(doc)
        @transaction_header = RawTransactionHeader.new(doc)
        @begin_date = parse_begin_date(doc)
        @subscriber_id = parse_subscriber_id(doc)
        @request_submit_timestamp = parse_request_submit_timestamp(doc)
      end

      def parse_request_submit_timestamp(doc)
        value_if_node(doc, "//etf:Loop_2750[etf:N1_ReportingCategory_2750/etf:N102__MemberReportingCategoryName = 'REQUEST SUBMIT TIMESTAMP']/etf:REF_ReportingCategoryReference_2750/etf:REF02__MemberReportingCategoryReferenceID")
      end

      def parse_begin_date(doc)
        value_if_node(doc, "//etf:Loop_2300/etf:DTP_HealthCoverageDates_2300[etf:DTP01__DateTimeQualifier = '348']/etf:DTP03__CoveragePeriod")
      end

      def parse_enrollment_group_id(doc)
        xpath(doc, "//etf:Loop_2300/etf:REF_HealthCoveragePolicyNumber_2300[etf:REF01__ReferenceIdentificationQualifier='1L']/etf:REF02__MemberGroupOrPolicyNumber").first.text
      end

      def parse_members(doc)
        xpath(doc, "//etf:Loop_2000").map { |n| RawMember.new(n) }
      end

      def parse_subscriber_id(doc)
        xpath(
          doc,
          "//etf:REF_SubscriberIdentifier_2000[etf:REF01__ReferenceIdentificationQualifier = '0F']" +
          "/etf:REF02__SubscriberIdentifier"
        ).first.text
      end

      def parse_broker(doc)
        broker_result = nil
        xpath(doc, "//etf:Loop_1000C/etf:N1_TPABrokerName_1000C").each do |node|
          broker_result = RawBroker.new
          broker_result.name = xpath(node, "etf:N102__TPAOrBrokerName").first.text
          broker_result.npn = xpath(node, "etf:N104__TPAOrBrokerIdentificationCode").first.text
        end
        broker_result
      end

      def parse_employer(doc)
        employer_result = nil
        xpath(doc, "//etf:Loop_1000A/etf:N1_SponsorName_1000A").each do |node|
          employer_result = RawEmployer.new
          employer_result.name = xpath(node, "etf:N102__PlanSponsorName").first.text
          employer_result.exchange_employer_id = xpath(node, "etf:N104__SponsorIdentifier").first.text
          if employer_result.name.strip == "DC0"
            employer_result = nil
          end
        end
        employer_result
      end

      def parse_carrier_id(doc)
        xpath(doc, "//etf:Loop_1000B/etf:N1_Payer_1000B/etf:N104__InsurerIdentificationCode").first.text
      end

      def persist!

        enrollment_group = EnrollmentGroup.find_or_create_enrollment_group(@enrollment_group_id)
        enrollment_group.s_id = @subscriber_id
        enrollment = Enrollment.find_or_update_enrollment(
            @plan.to_model(@carrier_id, @enrollment_group_id, @begin_date, @request_submit_timestamp)
          )

        ts = @transaction_header.to_model(@transmission_kind)
        ts.enrollment = enrollment
        msg = EdiTransmission.find_or_create_by(file_name: @file_name)
        msg.edi_transaction_sets.push ts


        # Enrollment.new(
        #   :carrier_to_bill => @carrier_to_bill,
        #   :hios_plan_id => @hios_id,
        #   :pre_amt_tot => @pre_amt_tot,
        #   :applied_aptc => @aptc,
        #   :tot_res_amt => @tot_res_amt,
        #   :employer_contribution => @emp_contribution,
        #   :carrier_id => carrier_id,
        #   :coverage_type => (@plan_kind.strip == 'HLT') ? "health" : "dental",
        #   :enrollment_group_id => enrollment_group_id,
        #   :benefit_begin_date => ben_begin
        #   :request_submit_timestamp => rs_timestamp
        # )


        members.each do |m|
          enrollment_group.merge_enrollee(m.to_model(@carrier_id))
          enrollment.merge_enrollment_member(m.to_enrollment_member)
        end

        members.each do |m|
          m.try_to_persist
        end
        unless @employer.nil?
          employer_model = Employer.find_or_create_employer(@employer.to_model)
          enrollment_group.employer_id = employer_model._id
        end

        unless @broker.nil?
          broker_model = Broker.find_or_create(@broker.to_model)
          enrollment_group.broker_id = broker_model._id
        end
        enrollment.save!
        enrollment_group.save!
        # ts.save!
        msg.save!
      end
    end
  end
end
