class Api::V1::ApplicationGroupsController < ApplicationController
  def index
    page_number = params[:page]
    page_number ||= 1
    @groups = ApplicationGroup.all.page(page_number).per(15)
  end
  
  def show
    @group = ApplicationGroup.find(params[:id])
  end
end
