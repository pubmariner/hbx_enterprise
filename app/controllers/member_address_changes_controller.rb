class MemberAddressChangesController < ApplicationController
  load_and_authorize_resource :class => "VocabUpload"

  def new
  end

  def create
    @file = params[:address_change_file]

    dl_name = download_filename(@file)

    requests = ChangeMemberAddressRequest.many_from_csv(@file.read, current_user.email)

    change_address = ChangeMemberAddress.new(transmitter)

    out_stream = CSV.generate do |csv|

      csv << ["member_id","type","address1","address2","city","state","zip","csl_number","status","errors"]
      requests.each do |request|
        error_logger = MemberAddressChangers::Csv.new(request, csv)
        change_address.execute(request.to_hash, error_logger)
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
