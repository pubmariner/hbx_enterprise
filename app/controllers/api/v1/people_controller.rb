class Api::V1::PeopleController < ApplicationController

  def index
    clean_hbx_member_id = Regexp.new(Regexp.escape(params[:hbx_id].to_s))

    @people = Person.where('members.hbx_member_id' => clean_hbx_member_id)

    page_number = params[:page] 
    page_number ||= 1
    @people = @people.page(page_number).per(15)
  end

  def show
    @person = Person.find(params[:id])
  end
end
