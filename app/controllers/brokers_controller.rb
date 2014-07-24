class BrokersController < ApplicationController
  def index
    @q = params[:q]

    if params[:q].present?
      @brokers = Broker.search(@q).page(params[:page]).per(12)
    else
      @brokers = Broker.page(params[:page]).per(12)
    end

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @brokers }
	  end
  end

  def show
		@broker = Broker.find(params[:id])
		@employers = @broker.employers

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @broker }
		end
  end
end
