HbxEnterprise::App.helpers do
  def hiphen_saperated_date(date)
    original_date = Date.strptime(date, "%Y%m%d")
    original_date.strftime("%Y-%m-%d")
  end

  def primary_office_location(office_locations)
    office_locations.detect do |office_location|
      office_location[:primary] == 'true'
    end
  end

  def plan_year_for_year(plan_years, year)
    plan_years.detect do |plan_year|
      Date.strptime(plan_year[:plan_year_start], "%Y%m%d").year.to_s == year
    end
  end

  def plan_exchange_id(hios_id, active_year)
    active_year + "" + hios_id.gsub(/[^0-9]/, '')
  end
end