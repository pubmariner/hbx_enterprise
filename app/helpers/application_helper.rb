HbxEnterprise::App.helpers do
  def hiphen_saperated_date(date)
    original_date = Date.strptime(date, "%Y%m%d")
    original_date.strftime("%Y-%m-%d")
  end
end