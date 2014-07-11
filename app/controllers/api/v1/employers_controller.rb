class Api::V1::EmployersController < ApplicationController
  def index
    fein = params[:fein]

    if(fein)
      @employers = Employer.where('fein' => /#{fein}/)
    else
      @employers = Employer.all
    end

    page_number = params[:page] 
    page_number ||= 1
    @employers = @employers.page(page_number).per(15)
  end

  def show
    @employer = Employer.find(params[:id])
  end
end
