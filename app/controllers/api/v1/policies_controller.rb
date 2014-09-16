class Api::V1::PoliciesController < ApplicationController
  def index
    clean_eg_id = Regexp.new(Regexp.escape(params[:enrollment_group_id].to_s))

    search = {"eg_id" => clean_eg_id}
    if(!params[:ids].empty?)
      search['_id'] = {"$in" => params[:ids]}
    end
    
    @policies = Policy.where(search)

    page_number = params[:page]
    page_number ||= 1
    @policies = @policies.page(page_number).per(15)
  end

  def show
    @policy = Policy.find(params[:id])
  end
end
