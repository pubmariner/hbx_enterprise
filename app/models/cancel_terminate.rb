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
  attr_accessor :operation, :reason, :benefit_end_date
  attr_accessor :people
  attr_accessor :policy

  def initialize(props = {})
    @policy_id = props[:policy_id]
    @policy = Policy.find(@policy_id.to_i)
    @operation = props[:operation]
    @reason = props[:reason]
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

  def subcriber_terminate
    if @people.any?{ |p| p.affect_selected == "1" && p.role == "self"}
      @people.each { |p| p.affect_selected = "1" }
    end
  end

  def add_benefit_end
    @policy.enrollees.each do |e|
      if included?(e.m_id)
        e.coverage_end = @benefit_end_date.to_date
        e.coverage_status = "inactive"
      end
    end
  end

  def included?(id)
    @people.any?{|p| p.affect_selected == "1" && p.m_id == id }
  end

  def to_cv
    subcriber_terminate
    add_benefit_end
    include_member_ids = @people.reject { |p| p.include_selected == "0" }.map(&:m_id)
    member_ids = include_member_ids

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

  def self.reasons
    [
      ["Reason", nil],
      ["death", "death"],
      ["divorce", "divorce"],
      ["age_off", "age_off"],
      ["termination_of_benefits", "termination_of_benefits"],
      ["change_of_location", "change_of_location"],
      ["reenrollment", "reenrollment"],
      ["non_payment", "non_payment"],
      ["notification_only", "notification_only"]
    ]
  end

end
