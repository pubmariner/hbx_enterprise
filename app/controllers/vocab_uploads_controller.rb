class VocabUploadsController < ApplicationController

  def new
    @vocab_upload = VocabUpload.new(:submitted_by => current_user.email)
  end

  def create
    @vocab_upload = VocabUpload.new(params[:vocab_upload])

    if @vocab_upload.save(self)
      flash_message(:success, "Upload successful.")
      redirect_to new_vocab_upload_path
    else
      flash_message(:error, "Upload failed.")
      render :new
    end
  end

  def group_has_incorrect_responsible_amount(details)
    flash_message(:error, "total_responsible_amount is incorrect. " + details_text(details))
  end

  def group_has_incorrect_premium_total(details)
    flash_message(:error, "premium_amount_total is incorrect. " + details_text(details))
  end

  def enrollee_has_incorrect_premium(details)
    flash_message(:error, "#{details[:name]}'s premium_amount is incorrect. " + details_text(details))
  end

  def premium_not_found
    flash_message(:error, "Premium was not found in the system.")
  end

  def details_text(details)
    "Expected $#{sprintf "%.2f", details[:expected]} but got $#{sprintf "%.2f", details[:provided]}."
  end
end
