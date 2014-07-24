class ChangeVocabulariesController < ApplicationController

  def new
    @change_vocabulary = ChangeVocabulary.new(params[:change_vocabulary])
  end

  def create
    @change_vocabulary = ChangeVocabulary.new(params[:change_vocabulary])

    redirect_to download_change_vocabularies_path({ :change_vocabulary => params[:change_vocabulary]})
  end

  def download
    @change_vocabulary = ChangeVocabulary.new(params[:change_vocabulary])

    generated_filename = "#{@change_vocabulary.policy_id}.xml"
    send_data(@change_vocabulary.to_cv, :type => "application/xml", :disposition => "attachment", :filename => generated_filename)
  end
end
