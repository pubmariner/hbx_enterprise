class UpdatePerson
  def initialize(listener, person_repo, address_changer, change_address_request_factory)
    @listener = listener
    @person_repo = person_repo
    @address_changer = address_changer
    @change_address_request_factory = change_address_request_factory
  end

  def execute(request)
    @request = request
    @person = @person_repo.find(request[:person_id])

    if(missing_home_address?(request))
      @listener.home_address_not_present
    end

    type_count_map = {}
    request[:addresses].each do |address|
      type_count_map[address[:address_type]] ||= 0
      type_count_map[address[:address_type]] += 1
    end

    type_count_map.each_pair do |type, count|
      max = 1
      if(count > max)
        @listener.too_many_addresses_of_type({address_type: 'home', max: max})
      end
    end

    return if @listener.has_errors?


    request[:addresses].each do |address_hash|
      requested_address = Address.new(address_hash)
      #addresses.one_of_type(requested_address.address_type)
      existing_address = @person.addresses.detect {|a| a.address_type == requested_address.address_type}
      if(existing_address.nil?)
        @person.addresses << requested_address
      else
        if(existing_address.address_type == 'home')
          if(!addresses_match?(existing_address, requested_address))

            change_address_request = @change_address_request_factory.for_member(@person.authority_member_id, requested_address, request[:current_user])
            @address_changer.execute(change_address_request, @listener)
            return if(@listener.has_errors?)
          end
        else
          update_address_from_request(existing_address, requested_address)
        end
      end
    end

    remove_addresses_not_in_request

    @person.save!
  end

  private
    def missing_home_address?(request)
      request[:addresses].detect { |a| a[:address_type] == 'home' }.nil?
    end
    
    def remove_addresses_not_in_request
      @person.addresses.each do |address|
        matching_type_in_request = @request[:addresses].detect { |a| a[:address_type] == address.address_type }

        if(matching_type_in_request.nil?)
          @person.addresses.delete(address)
        end
      end
    end
    def addresses_match?(a, b)
      a.address_type == b.address_type && \
      a.address_1 == b.address_1 && \
      a.address_2 == b.address_2 && \
      a.city == b.city && \
      a.state == b.state && \
      a.zip == b.zip
    end

    def update_address_from_request(address, request_address)
      address.address_type = request_address.address_type
      address.address_1 = request_address.address_1
      address.address_2 = request_address.address_2
      address.city = request_address.city
      address.state = request_address.state
      address.zip = request_address.zip
    end
end
