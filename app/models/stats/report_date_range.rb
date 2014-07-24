module Stats
class ReportDateRange < Hash

	attr_accessor	:start_date, :holiday_list

  def initialize(args = {})
    @start_date = args.fetch(:start_date) { Time.now }
	  @holiday_list = args.fetch(:start_date) { default_holidays }
    self.merge!(range_set(@start_date))
  end

	def range_set(moment)
		return nil unless moment.kind_of? Time

    local_time = moment.in_time_zone(::Time.zone)

	  {
    	start_time:       moment,
      normalized:  			normalized_time(local_time),
      year:         		local_time.year,
      month:        		local_time.month,
      day:          		local_time.day,
      wday:         		local_time.wday,
      day_of_year: 			local_time.yday,
			quarter_label: 		(local_time.month / 3.0).ceil,
			last_week:  			local_time.weeks_ago(1).all_week,
			last_month:  			local_time.months_ago(1).all_month,
			this_week:  			local_time.all_week,
			this_month:  			local_time.all_month,
			this_quarter:  		local_time.all_quarter,
			this_year:  			local_time.all_year,
			is_holiday?:  		is_holiday?(local_time),
	    hour:         		local_time.hour,
	    min:          		local_time.min,
	    sec:          		local_time.sec,
	    zone:         		::Time.zone.name,
	    offset:       		local_time.utc_offset
    }
	end

	def is_holiday?(val)
  	holiday_list.include?(val) ? true : false
  end

  def default_holidays
     ["11/11/2013", "11/28/2013, 12/25/2013",
                       "01/01/2014", "01/20/2014", "02/17/2014", "04/16/2014", "05/26/2014", "07/04/2014",
                       "09/01/2014", "10/13/2014", "11/11/2014", "11/27/2014", "12/25/2014",
                       "01/01/2015", "01/19/2015", "02/16/2015", "04/16/2015", "05/25/2015", "07/03/2015",
                       "09/07/2015", "10/12/2015", "11/11/2015", "11/26/2015", "12/25/2015",
                      ]
  end

protected
	def normalized_time(time)
	  ::Time.parse("#{ time.strftime("%F %T") } -0000").utc
  end

end
end
