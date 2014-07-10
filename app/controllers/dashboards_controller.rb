class DashboardsController < ApplicationController
	# layout 'dashboard'

  def index
  	#@total_lives = Person.count
  	@total_employers = Employer.count
  	@total_enrollments = Policy.count
  	@total_edi_transactions = Protocols::X12::TransactionSetEnrollment.count

    # This is where all transaction input is put to be displayed
    @transactions = {
      :increments => {},
      :months => {}
    };

    # This is the outline for what increments to create (the config)
    transactonIncrements = {
      "Last Week" => Time.now.weeks_ago( 1 ).all_week,
      "This Week" => Time.now.all_week,
      "This Month" => Time.now.all_month,
      "This Quarter" => Time.now.all_quarter,
      "This Year" => Time.now.all_year
    };

    # Loop through transaction increments and put them in the table to be displayed
    transactonIncrements.each_pair do |humanTime, timeObj|
      numTransactions = Protocols::X12::TransactionSetEnrollment.where( submitted_at: timeObj ).count;
      @transactions[ :increments ][ humanTime ] = numTransactions;
    end

    # A few other incremens
    @transactions[ :increments ][ "Total" ] = @total_edi_transactions;

    # This is the outline for prnumTransactionsous months to create (the config)
    @monthsToDisplay = 6;

    # Loop through the months and put them in the table to be displayed
    (1..@monthsToDisplay).each do |monthsAgo|
      timeObj = Time.now.months_ago( @monthsToDisplay - monthsAgo + 1 );
      numTransactions = Protocols::X12::TransactionSetEnrollment.where( submitted_at: timeObj.all_month ).count;
      @transactions[ :months ][ timeObj.strftime( "%B" ) ] = numTransactions;
    end  

    @response_metric = ResponseMetric.all
    @ambiguous_people_metric = AmbiguousPeopleMetric.all
    render :index;
  end
end
