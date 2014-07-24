class ApplicationGroupsController < ApplicationController
  def index
    @application_groups = ApplicationGroup.page(params[:page]).per(15)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @employers }
    end
  end

  def show
    @application_group = ApplicationGroup.find(params[:id])

  end

end
