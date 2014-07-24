module Stats
	class MetaTime < Moped::BSON::Document

		attr_accessor	:holiday_list

    def initialize(args = {})
	    args.each {|k,v|
	    	instance_variable_set("@#{k}", v) unless v.nil?} if args.is_a? Hash

	    dchbx_holidays
    end

	  def serialize(object)
      return nil if object.blank?
      # time = super(object)
      time = object
      local_time = object.in_time_zone(::Time.zone)
      {
        time:         time,
        normalized:   normalized_time(local_time),
        year:         local_time.year,
        month:        local_time.month,
        day:          local_time.day,
        wday:         local_time.wday,
        day_of_year: 	local_time.yday,
				quarter: 			(local_time.month / 3.0).ceil,
				is_holiday?:  is_holiday?(local_time),
        hour:         local_time.hour,
        min:          local_time.min,
        sec:          local_time.sec,
        zone:         ::Time.zone.name,
        offset:       local_time.utc_offset

      }.stringify_keys
    end


    def deserialize(object)
      return nil if object.blank?
      return super(object) if object.instance_of?(::Time)
      time = object['time'].getlocal unless Mongoid::Config.use_utc?
      zone = ActiveSupport::TimeZone[object['zone']]
      zone = ActiveSupport::TimeZone[object['offset']] if zone.nil?
      time.in_time_zone(zone)
    end

    def is_holiday?(val)
    	holiday_list.include?(val) ? true : false
    end

    def dchbx_holidays
      @holiday_list ||= ["11/11/2013", "11/28/2013, 12/25/2013",
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
