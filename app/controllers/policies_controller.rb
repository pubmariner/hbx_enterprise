class PoliciesController < ApplicationController
  def new
    @form = PolicyForm.new(application_group_id: params[:application_group_id])
  end

  def show
    @policy = Policy.find(params[:id])
    respond_to do |format|
      format.xml
    end
  end

  def create
    @form = PolicyForm.new(params[:policy_form])

    # @form.save
    redirect_to application_groups_path
  end

  def edit
    @policy = Policy.find(params[:id])

    @policy.enrollees.each { |e| e.include_checked = true }

    people_not_on_plan = @policy.household.people.reject { |p| p.policies.include?(@policy)}
    people_not_on_plan.each do |person|
      @policy.enrollees << Enrollee.new(m_id: person.authority_member_id)
    end
  end

  def update
    raise params.inspect
  end
end
