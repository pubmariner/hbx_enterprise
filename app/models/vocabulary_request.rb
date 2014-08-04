class VocabularyRequest
  attr_accessor :submitted_by
  attr_accessor :enrollment_group_list

  ALLOWED_ATTRIBUTES = [:enrollment_group_list, :submitted_by]

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  validates_presence_of :submitted_by
  validates_presence_of :enrollment_group_list

  def initialize(options={})
    options.each_pair do |k,v|
      if ALLOWED_ATTRIBUTES.include?(k.to_sym)
        self.send("#{k}=", v)
      end
    end
  end

  def save
    return(false) unless self.valid?
  end

  def persisted?
    false
  end
end
