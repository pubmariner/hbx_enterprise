class ApplicationGroup
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::Versioning
  include Mongoid::Paranoia
  include AASM

  field :aasm_state, type: String
  field :active, type: Boolean, default: true   # ApplicationGroup active on the Exchange?
  field :notes, type: String

  index({:aasm_state => 1})

  index({"person_relationships.subject_person" => 1})
  index({"person_relationships.object_person" => 1})

	has_many :households, autosave: true
  has_many :people

  embeds_many :special_enrollment_periods, cascade_callbacks: true
  accepts_nested_attributes_for :special_enrollment_periods, reject_if: proc { |attribs| attribs['start_date'].blank? }, allow_destroy: true

  embeds_many :person_relationships

  def applicant
    unless person_relationships.first.subject_person.nil?
      pid = person_relationships.first.subject_person
      Person.find(pid)
    end
  end

  # List of SEPs active for this Household on this or specified date
  def active_seps(day = Date.today)
    special_enrollment_periods.find_all { |sep| (sep.start_date..sep.end_date).include?(day) }
  end

  # single SEP with latest end date from list of active SEPs
  def current_sep
    active_seps.max { |sep| sep.end_date }
  end

  def self.default_search_order
    [
      ["name_last", 1],
      ["name_first", 1]
    ]
  end

  def people_relationship_map
    map = Hash.new
    people.each do |person|      
      map[person] = person_relationships.detect { |r| r.object_person == person.id }.relationship_kind
    end
    map
  end
  
  aasm do
    state :closed_enrollment, initial: true
    state :open_enrollment_period
    state :special_enrollment_period

    event :open_enrollment do
      transitions from: [:closed_enrollment, :special_enrollment_period, :open_enrollment_period], to: :open_enrollment_period
    end

    # TODO - what are rules around special enrollments that extend past open enrollment?
    event :special_enrollment do
      transitions from: [:closed_enrollment, :open_enrollment_period, :special_enrollment_period], to: :special_enrollment_period
    end

    event :close_enrollment do
      transitions from: [:open_enrollment_period, :special_enrollment_period, :closed_enrollment], to: :closed_enrollment
    end
  end


end
