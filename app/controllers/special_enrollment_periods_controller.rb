class SpecialEnrollmentPeriodsController < ApplicationController

  def new
    @sep = SpecialEnrollmentPeriod.new(application_group_id: params[:application_group_id])
    @application_group = ApplicationGroup.find(params[:application_group_id])
    
  end

  def create
    @application_group = ApplicationGroup.find(params[:application_group_id])
    @sep = SpecialEnrollmentPeriod.new(params[:special_enrollment_period])

    if(@sep.valid?)
      @application_group.special_enrollment_periods << @sep
      redirect_to @application_group
    else
      render action: "new"
    end
  end
end
