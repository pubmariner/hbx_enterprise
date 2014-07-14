class Api::V1::PeopleController < ApplicationController

  def index
    hbx_member_id = params[:hbx_id]

    if(hbx_member_id)
      @people = Person.where('members.hbx_member_id' => /#{hbx_member_id}/)
    else
      @people = Person.all
    end

    page_number = params[:page] 
    page_number ||= 1
    @people = @people.page(page_number).per(15)
  end

  def show
    @person = Person.find(params[:id])
  end
end
