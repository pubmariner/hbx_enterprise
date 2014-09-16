require 'net/http'

module CanonicalVocabulary
	class IrsHouseholdSerializer
		def initialize
			@person_id = "53e6921beb899ad9ca014faf"
			@token_id = "1LGx9y5uvcsR-syqzTob"
		end

		def serialize
			builder.to_xml
		end

		# "54130692d2b38ba144000da9" 05, 4
		# "54104bbad2b38bdbc0000105" 25, 4
		# "54130b48d2b38ba14400d904" 02, 4
		# "53e912f1eb899ad2e4001ec9" 03, 2

		def builder
			# Application Group ID: 53e690a3eb899ad9ca00d28d
			Nokogiri::XML::Builder.new do |xml|
				xml.IndividualExchange do |xml|
					xml.HealthExchangeId "00.000.000.000.000"
					group_xml = Net::HTTP.get(URI.parse("http://localhost:3000/api/v1/application_groups/53e691aeeb899ad9ca012939?user_token=zUzBsoTSKPbvXCQsB4Ky"))
					@app_group = Parsers::Xml::IrsReports::ApplicationGroup.new(group_xml)
					next if @app_group.individual_policies.empty?
					serialize_irs_household_grp(xml)
				end
			end
		end

		def serialize_irs_household_grp(xml)
			xml.IRSHouseholdGrp do |xml|
				xml.IRSGroupIdentificationNum
				@individual_policies = []
				@app_group.irs_households.each do |household|
					serialize_taxhousehold(xml, household)
					serialize_insurance_policies(xml)
				end
			end
		end

		def serialize_insurance_policies(xml)
			@individual_policies.uniq.each do |policy|
				# policy_xml = Net::HTTP.get(URI.parse("#{policy}?user_token=zUzBsoTSKPbvXCQsB4Ky"))
				# policy = Parsers::Xml::IrsReports::Policy.new(policy_xml)
				xml.InsurancePolicy do |xml|
					xml.InsuranceCoverage do |xml|
						xml.ApplicableCoverageMonthNum policy.id
						xml.QHPPolicyNum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
						xml.QHPId policy.qhp_id
						xml.PediatricDentalPlanPremiumInd "N"
						xml.QHPIssuerEIN 000000000
						xml.IssuerNm
						xml.PolicyCoverageStartDt "1957-08-13"
						xml.PolicyCoverageEndDt "1957-08-13"
						xml.TotalQHPMonthlyPremiumAmt policy.total_monthly_premium
						xml.APTCPaymentAmt policy.household_aptc
						policy.individuals.each do |individual_xml|
							xml.CoveredIndividual do |xml|
								xml.InsuredPerson do |xml|
									individual = Parsers::Xml::IrsReports::Individual.new(individual_xml)
									serialize_name_ssn_dob(xml, individual)
								end
							end
						end
						xml.CoverageStartDt "1957-08-13"
						xml.CoverageEndDt "1957-08-13"
					end
				end	
			end
		end

		def serialize_taxhousehold(xml, household=nil)
			household = Parsers::Xml::IrsReports::Household.new(household)
			xml.TaxHousehold do |xml|
				xml.TaxHouseholdCoverage do |xml|
					xml.Household do |xml|
						applicants_xml = @app_group.applicants_xml
						primary_xml = applicants_xml[household.primary]
						individual = Parsers::Xml::IrsReports::Individual.new(primary_xml)
						serialize_individual(xml, individual)
						serialize_members = Proc.new do |xml, members|
							members.each do |key, val|
								applicant_xml = applicants_xml[key]
								individual = Parsers::Xml::IrsReports::Individual.new(applicant_xml)
								serialize_individual(xml, individual, val.camelcase)
							end
						end
						serialize_members.call(xml, household.spouse)
						serialize_members.call(xml, household.dependents)
					  serialize_associated_policies(xml, household)
					end
				end
			end
		end

		def serialize_associated_policies(xml, household)
			policies = []
			household.all_members.each do |member|
				policies << @app_group.individual_policy_holders[member]
			end

			policy_ids = []
			policies.flatten.uniq.each do |policy|
				if @app_group.individual_policies.include?(policy)
					policy_ids << policy.match(/\d+$/)[0]
				end
			end

			policies_xml = Net::HTTP.get(URI.parse("http://localhost:3000/api/v1/policies?ids[]=#{policy_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
			parser = Nokogiri::XML(policies_xml).root
			parser.xpath("n1:policy").each do |policy_xml|
				policy = Parsers::Xml::IrsReports::Policy.new(policy_xml)
				serialize_policy(xml, policy)
				@individual_policies << policy
			end
		end

		def serialize_policy(xml, policy)
			xml.AssociatedPolicy do |xml|
				xml.QHPPolicyNum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
				xml.QHPIssuerEIN 000000000
				xml.PediatricDentalPlanPremiumInd "N"
				xml.SLCSPAdjMonthlyPremiumAmt 0
				xml.HouseholdAPTCAmt policy.household_aptc
				xml.TotalHsldMonthlyPremiumAmt policy.total_monthly_premium			
			end
		end

		def serialize_individual(xml, individual, relation="Primary")
			xml.send("#{relation}Grp") do |xml|
				xml.send(relation) do |xml|
					serialize_name_ssn_dob(xml, individual)
					individual.addresses.each do |address|
						serialize_address(xml, address)
					end
				end

				individual.employers.each do |employer_url|
					employer_xml = Net::HTTP.get(URI.parse("#{employer_url}?user_token=zUzBsoTSKPbvXCQsB4Ky"))
					employer = Parsers::Xml::IrsReports::Employer.new(employer_xml)
					serialize_employer(xml, employer)
				end
			end
		end

		def serialize_name_ssn_dob(xml, individual)
			xml.CompletePersonName do |xml|
				xml.PersonFirstName individual.name_first
				xml.PersonMiddleName individual.name_middle
				xml.PersonLastName individual.name_last
				xml.SuffixName individual.name_suffix
			end

			xml.SSN individual.ssn
			xml.BirthDt individual.dob
		end

		def serialize_employer(xml, employer)
			xml.EmployerMEC do |xml|
				xml.EIN employer.ein
				xml.BusinessName do |xml|
					xml.BusinessNameLine1 employer.name
					xml.BusinessNameLine2
				end

				xml.BusinessAddressGrp do |xml|
					employer.addresses.each do |address|
						serialize_address(xml, address)     
					end
				end
				xml.MECStatusInd "Y"
			end
		end

		def serialize_address(xml, address)
			xml.USAddressGrp do |xml|
				xml.AddressLine1Txt address[:address_1]
				xml.AddressLine2Txt address[:address_2]
				xml.CityNm address[:city]
				xml.USStateCd address[:state]
				xml.USZIPCd address[:postal_code]
				xml.USZIPExtensionCd
			end			
		end
	end
end
