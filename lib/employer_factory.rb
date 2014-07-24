require 'open-uri'
require 'nokogiri'

class EmployerFactory
  def create_many_from_xml(xml)
    employers = []
    doc = Nokogiri::XML(xml)
    doc.css('employers employer').each do |emp|
      employers << create_employer(ExposesEmployerXml.new(emp))
    end

    employers
  end

  private

  def create_employer(employer_data)
    employer = Employer.new(
      :name => employer_data.name,
      :fein => employer_data.fein,
      :hbx_id => employer_data.employer_exchange_id,
      :sic_code => employer_data.sic_code,
      :fte_count => employer_data.fte_count,
      :pte_count => employer_data.pte_count,
      :open_enrollment_start => employer_data.open_enrollment_start,
      :open_enrollment_end => employer_data.open_enrollment_end,
      :plan_year_start => employer_data.plan_year_start,
      :plan_year_end => employer_data.plan_year_end,
      :name_pfx => employer_data.contact.prefix,
      :name_first => employer_data.contact.first_name,
      :name_middle => employer_data.contact.middle_initial,
      :name_last => employer_data.contact.last_name,
      :name_sfx => employer_data.contact.suffix,
      #exchange_status?
      #exchange_version?
      :notes => employer_data.notes
    )

    if !employer_data.contact.street1.blank?
      employer.addresses << create_address(employer_data.contact)
    end

    if !employer_data.contact.phone_number.blank?
      employer.phones << create_phone(employer_data.contact)
    end

    if !employer_data.contact.email_address.blank?
      employer.emails << create_emails(employer_data.contact)
    end

    employer_data.plans.each do |plan_data|
      employer.elected_plans << create_elected_plan(plan_data)
    end

    employer.broker = Broker.find_by_npn(employer_data.broker_npn_id)

    employer.carriers = carriers_for_plans(employer.elected_plans)

    employer
  end

  def carriers_for_plans(elected_plans)
    Carrier.find(elected_plans.collect { |p| p.carrier_id }.uniq)
  end

  def create_address(contact_data)
    Address.new(
      :address_type => 'work',
      :address_1 => contact_data.street1,
      :address_2 => contact_data.street2,
      :city => contact_data.city,
      :state => contact_data.state,
      :zip => contact_data.zip
      )
  end

  def create_phone(contact_data)
    Phone.new(
    :phone_type => 'work',
    :phone_number => contact_data.phone_number.gsub(/[^0-9]/,""),
    )
  end

  def create_emails(contact_data)
    Email.new(
      :email_type => contact_data.email_type.downcase,
      :email_address => contact_data.email_address,
    )
  end

  def create_elected_plan(plan_data)
    plan = Plan.find_by_hios_id(plan_data.qhp_id)
    raise self.hios_id.inspect if plan.nil?

    ElectedPlan.new(
      :carrier_id => plan.carrier_id,
      :qhp_id => plan_data.qhp_id,
      :coverage_type => plan_data.coverage_type,
      :metal_level => plan.metal_level,
      :hbx_plan_id => plan.hbx_plan_id,
      :original_effective_date => plan_data.original_effective_date,
      :plan_name => plan.name,
      :carrier_policy_number => plan_data.policy_number,
      :carrier_employer_group_id => plan_data.group_id
      )
  end
end
