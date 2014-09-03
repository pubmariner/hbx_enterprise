class MemberAddressChangesController < ApplicationController
  load_and_authorize_resource :class => "VocabUpload"

  def new
  end

  def create
    @file = params[:address_change_file]

    dl_name = download_filename(@file)

    requests = CsvRequest.create_many(@file.read.force_encoding('utf-8'), current_user.email)

    change_address = ChangeMemberAddress.new(transmitter)

    out_stream = CSV.generate do |csv|

      csv << ["member_id","type","address1","address2","city","state","zip","csl_number","transmit","status","errors"]
      requests.each do |csv_request|
        error_logger = MemberAddressChangers::Csv.new(csv_request, csv)
        request = ChangeAddressRequest.from_csv_request(csv_request.to_hash)
        change_address.execute(request, error_logger)
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
