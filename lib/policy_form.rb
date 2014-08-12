class PolicyForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  #include ActiveModel::Validations


  SubmittedPerson = Struct.new(:include_selected, :name, :hbx_member_id, :relationship, :birth_date) do
    def initialize(h)
      super(*h.values_at(:include_selected, :name, :hbx_member_id, :relationship, :birth_date))
    end

    def persisted?
      false
    end
  end

  attr_accessor :application_group_id
  attr_accessor :application_group
  attr_accessor :carriers
  attr_accessor :coverage_start
  attr_accessor :people
  attr_accessor :carrier_id
  attr_accessor :plan_id
  attr_accessor :credit
  attr_accessor :carrier_to_bill
  attr_accessor :employer
  attr_accessor :transmit_to_carrier
  attr_accessor :employer_id

  def initialize(params = {})
    @application_group_id = params[:application_group_id]
    @application_group = ApplicationGroup.find(@application_group_id)
    @carriers = Carrier.all

      
    @people = @application_group.people.map do |p| 
      SubmittedPerson.new(
        name: p.name_full, 
        include_selected: true, 
        hbx_member_id: p.authority_member_id, 
        relationship: '',
        birth_date: p.authority_member.dob
        )
    end
  end
  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def people_attributes=(pas)
  end

  private

  def persist!
  end
end
