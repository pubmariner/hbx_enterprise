class EmployeesController < ApplicationController

	def new
	  @employer = Employer.find(params[:employer_id])
	  @person = Person.new
    @person.members.build
    @person.addresses.build
    @person.phones.build
    @person.emails.build

    @person.addresses.first.city = "Washington"
    @person.addresses.first.state = "DC"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
	end

	def create
    @person = Person.new(params[:person])
		@employer = Employer.find(params[:employer_id])
    @person.employer = @employer
    @person.updated_by = current_user.email unless current_user.nil?

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @employer, notice: 'Employee was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render action: "new" }
        format.json { render json: @employer.errors, status: :unprocessable_entity }
      end
    end
	end


  def show
    @person = Person.find(params[:id])
    @employer = Employer.find(params[:employer_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @person }
    end
  end


  def edit
    @person = Person.find(params[:id])
    @employer = Employer.find(params[:employer_id])

    @person.members.build if @person.members.empty?
    @person.addresses.build if @person.addresses.empty?
    @person.phones.build if @person.phones.empty?
    @person.emails.build if @person.emails.empty?
  end


  def update
    @person = Person.find(params[:id])
    @employer = Employer.find(params[:employer_id])
    @person.employer = @employer
    @person.updated_by = current_user.email unless current_user.nil?

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Employee was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def compare
    @person = Person.find(params[:id])
    @updated_person = Person.new(params[:person])

    # @person.members
    # assoc_attributes = anything ending with an _id

    admin_attributes = %w[_id created_at deleted_at updated_at updated_by]
    @person_fields = Person.attribute_names.reject { |attrib| admin_attributes.include?(attrib) }
  end


  def terminate

  end


end
