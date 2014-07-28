class PeopleController < ApplicationController
  def index
    @q = params[:q]
    @qf = params[:qf]
    @qd = params[:qd]

    if params[:q].present?
      @people = Person.search(@q, @qf, @qd).page(params[:page]).per(15)
    else
      @people = Person.page(params[:page]).per(15)
    end

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @people }
	  end
  end

  def show
		@person = Person.find(params[:id])

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @person }
		end
  end

  def new
    @person = Person.new(application_group_id: params[:application_group_id])
    build_nested_models

    @person.addresses.first.city = "Washington"
    @person.addresses.first.state = "DC"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  def edit
    @person = Person.find(params[:id])

    build_nested_models
  end

  def create
    @person = Person.new(params[:person])
    @person.updated_by = current_user.email unless current_user.nil?

    respond_to do |format|
      if @person.save
        AddPerson.new.execute(@person, @person.relationship)
        format.html { redirect_to @person.application_group, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @person = Person.find(params[:id])
    update_person(params[:person])
  end

  def compare
    @person = Person.find(params[:id])
    @person.assign_attributes(params[:person], without_protection: true)

    # Validate model and each embedded association
    render action: "edit" unless @person.valid? && @person.all_embedded_documents_valid?

    @updates = params[:person] || {}

    @delta = @person.changes_with_embedded || {}
    deletion_deltas = DeletionDeltaExtractor.new(params[:person]).extract

    @delta.deep_merge!(deletion_deltas)
  end

  def persist_and_transmit
    @person = Person.find(params[:id])
    @updated_properties = Hash.new.merge(JSON.parse(params[:person]))

    update_person(@updated_properties)
  end

  def update_person(updates)
    original_person = Person.find(params[:id])
    original_person.assign_attributes(updates)
    delta = original_person.changes_with_embedded

    respond_to do |format|
      if @person.update_attributes(updates)
        # Protocols::Notifier.update_notification(@person, delta)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def assign_authority_id
    person = Person.find(params[:id])
    person.authority_member = params[:radio][:authority_id]
    person.save!

    respond_to do |format|
      format.html { redirect_to person, notice: "Person's Authority Member ID updated." }
    end
  end

  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_path }
      format.json { head :no_content }
    end
  end

private
  def build_nested_models
    @person.members.build if @person.members.empty?
    @person.addresses.build if @person.addresses.empty?
    @person.phones.build if @person.phones.empty?
    @person.emails.build if @person.emails.empty?
  end

end
