class PersonDiff
  AddressDiff = Struct.new(:before, :after)

  attr_reader :addresses_added, :addresses_removed, :addresses_changed

  def initialize(params)
    @old_person = Person.find_by_id(params[:id])
    @new_person = Person.find_by_id(params[:id])
    @new_person.assign_attributes(params[:person])
    
    calculate_address_changes(@old_person, @new_person)
  end

  def calculate_address_changes(old_person, new_person)
    @addresses_added = []
    @addresses_removed = []
    @addresses_changed = []
    Address::TYPES.each do |t|
      old_address = @old_person.address_of(t)
      new_address = @new_person.address_of(t)
      case address_change_type(old_address, new_address)
      when :add
        @addresses_added << new_address
      when :delete
        @addresses_removed << old_address
      when :change
        @addresses_changed << AddressDiff.new(old_address, new_address)
      else
      end
    end
  end

  def address_change_type(old_address, new_address)
    if old_address.nil?
      new_address.nil? ? :unchanged : :add
    elsif new_address.nil?
      :delete
    else
      old_address.match(new_address) ? :unchanged : :change
    end
  end
end
