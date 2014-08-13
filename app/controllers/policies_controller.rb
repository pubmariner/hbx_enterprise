class PoliciesController < ApplicationController
  def new
    @form = PolicyForm.new(application_group_id: params[:application_group_id], household_id: params[:household_id])
  end

  def show
    @policy = Policy.find(params[:id])
    respond_to do |format|
      format.xml
    end
  end

  def create
    request = CreatePolicyRequestFactory.from_form(params[:policy_form])
    raise request.inspect

    CreatePolicy.new.execute(request)
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

  def cancelterminate
    @cancel_terminate = CancelTerminate.new(params[:cancel_terminate])
  end

  def transmit
    @cancel_terminate = CancelTerminate.new(params[:cancel_terminate])

    if params[:cancel_terminate][:transmit] == "1"

    else
      generated_filename = "#{@cancel_terminate.policy_id}.xml"
      send_data(@cancel_terminate.to_cv, :type => "application/xml", :disposition => "attachment", :filename => generated_filename)
    end

  end

end
