module Stats
  class DateDimension

		attr_accessor	:start_date, :end_date, :holiday_list, :fiscal_year_offset_month

    # Start date is first day of DCHBX go-live: Oct 1, 2013
    def initialize(start_date = "01/10/2013", end_date = Time.now, fiscal_year_offset_month = 10)
      # @start_date = start_date.to_date
      # @end_date = end_date.to_date
      @start_date = parse_datetime(start_date)
      @end_date = parse_datetime(end_date)
      @fiscal_year_offset_month = fiscal_year_offset_month.to_i
      @holiday_list = dchbx_holidays
    end

    # Holidays listed from DCHBX go-live to end of 2015
    def dchbx_holidays
      return [] if Time.now.year > 2015
      @holiday_list ||= ["11/11/2013", "11/28/2013, 12/25/2013",
                         "01/01/2014", "01/20/2014", "02/17/2014", "04/16/2014", "05/26/2014", "07/04/2014",
                         "09/01/2014", "10/13/2014", "11/11/2014", "11/27/2014", "12/25/2014",
                         "01/01/2015", "01/19/2015", "02/16/2015", "04/16/2015", "05/25/2015", "07/03/2015",
                         "09/07/2015", "10/12/2015", "11/11/2015", "11/26/2015", "12/25/2015",
                        ]
    end

     # Returns an array of hashes representing current month-to-date ranges in the dimension
    def month_to_date_range
      month_start_date = DateTime.strptime("#{Time.now.month}/01/#{Time.now.year}", "%m/%d/%Y")
      (month_start_date..@end_date).map { |date| range_from_date(date) }
    end

     # Returns an array of hashes representing current year-to-date ranges in the dimension
    def year_to_date_range
      year_start_date = DateTime.strptime("01/01/#{Time.now.year}", "%m/%d/%Y")
      (year_start_date..@end_date).map { |date| range_from_date(date) }
    end

    # Returns an array of hashes representing date ranges in the dimension
    def date_range(options={})
      (@start_date..@end_date).map { |date| range_from_date(date) }
    end

  protected

    # Returns a hash representing a date range in the dimension. The values for each range are
    # accessed by name
    def range_from_date(date)
      time = date.to_time # need methods only available in Time
      range = {}
      range[:date] = time.strftime("%m/%d/%Y")
      range[:full_date] = time.strftime("%B %d,%Y")

      range[:day_of_week_name] = time.strftime("%A")
      range[:day_in_week_name] = range[:day_of_week_name] # alias
      range[:day_number_in_week] = time.wday
      range[:day_number_in_calendar_month] = time.day
      range[:day_number_in_calendar_year] = time.yday

      # range[:calendar_week] = "Week #{time.week}"
      # range[:calendar_week_number] = time.week

      range[:calendar_year] = "#{time.year}"
      range[:calendar_year_month] = time.strftime("%Y-%m")
      range[:calendar_month_number] = time.month
      range[:calendar_month_name] = time.strftime("%B")
      range[:calendar_quarter_number] = (range[:calendar_month_number] / 3.0).ceil
      range[:calendar_quarter_name] = "Q-" + range[:calendar_quarter_number].to_s
      range[:calendar_year_quarter] = "#{time.strftime('%Y')}-#{range[:calendar_quarter_number]}"

      range[:is_holiday?] = holiday_list.include?(range[:date]) ? true : false
      # range[:is_open_enrollment?] = false
      range[:mongodb_date_stamp] = date

      # range[:day_number_in_fiscal_month] = time.day # should this be different from CY?
      # range[:day_number_in_fiscal_year] = time.fiscal_year_yday(fiscal_year_offset_month)
      # range[:fiscal_week] = "FY Week #{time.fiscal_year_week(fiscal_year_offset_month)}"
      # range[:fiscal_week_number_in_year] = time.fiscal_year_week(fiscal_year_offset_month) # DEPRECATED
      # range[:fiscal_week_number] = time.fiscal_year_week(fiscal_year_offset_month)
      # range[:fiscal_month] = time.fiscal_year_month(fiscal_year_offset_month)
      # range[:fiscal_month_number] = time.fiscal_year_month(fiscal_year_offset_month)
      # range[:fiscal_month_number_in_year] = time.fiscal_year_month(fiscal_year_offset_month) # DEPRECATED
      # range[:fiscal_year_month] = "FY#{time.fiscal_year(fiscal_year_offset_month)}-" + time.fiscal_year_month(fiscal_year_offset_month).to_s.rjust(2, '0')
      # range[:fiscal_quarter] = "FY Q#{time.fiscal_year_quarter(fiscal_year_offset_month)}"
      # range[:fiscal_year_quarter] = "FY#{time.fiscal_year(fiscal_year_offset_month)}-Q#{time.fiscal_year_quarter(fiscal_year_offset_month)}"
      # range[:fiscal_quarter_number] = time.fiscal_year_quarter(fiscal_year_offset_month) # DEPRECATED
      # range[:fiscal_year_quarter_number] = time.fiscal_year_quarter(fiscal_year_offset_month)
      # range[:fiscal_year] = "FY#{time.fiscal_year(fiscal_year_offset_month)}"
      # range[:fiscal_year_number] = time.fiscal_year(fiscal_year_offset_month)
      # range[:weekday_indicator] = weekday_indicators[time.wday]

      range
    end

    def parse_datetime(value)
      case value
        when ::String
          ::DateTime.parse(value)
        when ::Time
          offset = ActiveSupport::TimeZone.seconds_to_utc_offset(value.utc_offset)
          ::DateTime.new(value.year, value.month, value.day, value.hour, value.min, value.sec, offset)
        when ::Date
          ::DateTime.new(value.year, value.month, value.day)
        when ::Array
          ::DateTime.new(*value)
        else
          value
      end
    end

    def normalized_time(time)
      ::Time.parse("#{ time.strftime("%F %T") } -0000").utc
    end
  end
end
