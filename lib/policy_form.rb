class PolicyForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  #include ActiveModel::Validations


  SubmittedPerson = Struct.new(:include_selected, :name) do
    def initialize(h)
      super(*h.values_at(:include_selected, :name))
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

  def initialize(params = {})
    @application_group_id = params[:application_group_id]
    @application_group = ApplicationGroup.find(@application_group_id)
    @carriers = Carrier.all

      
    @people = @application_group.people.map { |p| SubmittedPerson.new({name: p.name_full, include_selected: true}) }
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
    # TODO 
    #create Enrollees
      #calcuate premium
    #create policy
    @policy = Policy.new(
      :plan_id => @plan_id,
      :enrollment_group_id => eg_id,
      :carrier_id => @carrier_id,
      # :tot_res_amt => reporting_categories.tot_res_amt,
      # :pre_amt_tot => reporting_categories.pre_amt_tot,
      # :applied_aptc => reporting_categories.applied_aptc,
      # :tot_emp_res_amt => reporting_categories.tot_emp_res_amt,
      # :carrier_to_bill => reporting_categories.carrier_to_bill?,
      # :employer_id => employer_id,
      # :broker_id => broker_id,
      # :responsible_party_id => rp_id,
      # :enrollees => []
    )

    @policy.enrollees
  end
end
