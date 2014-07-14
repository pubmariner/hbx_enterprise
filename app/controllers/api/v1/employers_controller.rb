class Api::V1::EmployersController < ApplicationController
  def index
    @employers = Employer.where("hbx_id" => /#{params[:hbx_id]}/, "fein" => /#{params[:fein]}/)

    page_number = params[:page] 
    page_number ||= 1
    @employers = @employers.page(page_number).per(15)
  end

  def show
    @employer = Employer.find(params[:id])
  end
end
