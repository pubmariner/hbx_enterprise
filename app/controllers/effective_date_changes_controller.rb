class EffectiveDateChangesController < ApplicationController
    load_and_authorize_resource :class => "VocabUpload"

  def new
  end

  def create
    @file = params[:effective_date_change_file]

    dl_name = download_filename(@file)

    requests = CsvRequest.create_many(@file.read.force_encoding('utf-8'), current_user.email)

    change_effective_date = ChangeEffectiveDate.new(transmitter)

    out_stream = CSV.generate do |csv|

      csv << ["policy_id","effective_date","csl_number","status","errors"]
      requests.each do |request|
        error_logger = EffectiveDateChangers::Csv.new(request, csv)
        change_effective_date.execute(request.to_hash, error_logger)
      end

    end

    send_data out_stream, :filename => dl_name, :type => "text/csv", :disposition => "attachment"
  end

  def transmitter
    TransmitPolicyMaintenance.new
  end

  def download_filename(file)
    fname = file.original_filename
    File.basename(fname,File.extname(fname)) + "_status.csv"
  end

end
