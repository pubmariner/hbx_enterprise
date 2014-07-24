class EnrollmentAddress
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  attr_accessor :id
  attr_accessor :name
  attr_accessor :people
  attr_accessor :address_1, :address_2, :city, :state, :zip

  validates_presence_of :address_1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip

  KEYS = [:id, :people, :address_1, :address_2, :city, :state, :zip, :name]

  def initialize(data = {})
    data.each_pair do |k, v|
      if KEYS.include?(k.to_sym)
        self.send("#{k}=", v)
      end
    end
  end

  def save
    if self.valid?
      save_each_address
    else
      false
    end
  end

  def update_attributes(data = {})
    data.each_pair do |k,v|
      if KEYS.include?(k.to_sym)
        self.send("#{k}=", v)
      end
    end
    save
  end

  def self.find(person_id)
    en = Person.find(person_id)
    people_ids = en.associated_for_address
    address = en.home_address
    self.new(ActiveSupport::HashWithIndifferentAccess.new(address.attributes.dup.merge({:people => people_ids, :id => en._id.to_s, :name => en.name_full})))
  end

  def to_address_hash
    {
      :address_1 => self.address_1,
      :address_2 => self.address_2,
      :city => self.city,
      :state => self.state,
      :zip => self.zip
    }
  end

  def save_each_address
    peeps = Person.find(people)
    peeps.each do |per|
      home_addys = per.addresses.select(&:home?)
      home_addys.each do |addy|
        per.addresses.delete(addy)
      end
      per.addresses << Address.new(to_address_hash.merge({:address_type => "home"}))
      per.touch
      per.save!
    end
  end

  def persisted?; true; end

end
