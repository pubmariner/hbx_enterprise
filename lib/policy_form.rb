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

  def initialize(params = {})
    @application_group = ApplicationGroup.find(params[:application_group_id])
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
    # @policy = Policy.create!
    # @user = @company.users.create!(name: name, email: email)
  end
end
