class Api::V1::PoliciesController < ApplicationController
  def index
    @policies = Policy.all
    
    page_number = params[:page] 
    page_number ||= 1
    @policies = @policies.page(page_number).per(15)
  end

  def show
    @policy = Policy.find(params[:id])
  end
end
