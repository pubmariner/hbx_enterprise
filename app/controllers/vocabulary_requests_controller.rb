class VocabularyRequestsController < ApplicationController

  def new
    @vocabulary_request = VocabularyRequest.new(:submitted_by => current_user.email)
  end

  def create
    @vocabulary_request = VocabularyRequest.new(params[:vocabulary_request])

    if @vocabulary_request.save
      flash_message(:success, "Vocabulary Request successful.")
      redirect_to new_vocabulary_request_path
    else
      render :new
    end
  end
end
