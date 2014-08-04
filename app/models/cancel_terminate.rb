class CancelTerminate
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  CancelTerminate  = Struct.new(:affect_selected, :include_selected, :m_id, :name, :role) do
    def initialize(h)
      super(*h.values_at(:affect_selected, :include_selected, :m_id, :name, :role))
    end

    def persisted?
      false
    end
  end

  attr_accessor :policy_id
  attr_accessor :operation, :benefit_end_date
  attr_accessor :people
  attr_accessor :policy

  def initialize(props = {})
    @policy_id = props[:policy_id]
    @policy = Policy.find(@policy_id.to_i)
    @operation = props[:operation]
    @reason = "termination_of_benefits"
    @benefit_end_date = props[:benefit_end_date]
    ppl_hash = props.fetch(:people_attributes) { {} }
    if ppl_hash.empty?
      @people = map_people_from_policy(@policy)
    else
      @people = ppl_hash.values.map { |person| CancelTerminate.new(person) }
    end
  end

  def map_people_from_policy(enroll)
    policy.enrollees.map do |em|
      per = em.person
      CancelTerminate.new({m_id: em.m_id, name: per.name_full, role: em.rel_code, affect_selected: true, include_selected: true})
    end
  end

  def to_cv
    member_ids = @people.reject { |p| p.affect_selected == "0" || p.affect_selected.nil? }.map(&:m_id)
    include_member_ids = @people.reject { |p| p.include_selected == "0" }.map(&:m_id)
    ser = CanonicalVocabulary::MaintenanceSerializer.new(
      @policy,
      @operation,
      @reason,
      member_ids,
      include_member_ids
    )
    ser.serialize
  end

  def people_attributes=(pas)
  end

  def persisted?; false; end

  def self.operations
    [
      ["Operation Type", nil],
      ["cancel", "cancel"],
      ["terminate", "terminate"]
    ]
  end

end
