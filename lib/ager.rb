class Ager
  def initialize(birth_date)
    @birth_date = birth_date
  end

  def age_as_of(date)
    age = date.year - @birth_date.year
    age -= 1 if before_birthday_this_year?(date)
    age
  end

  private

  def before_birthday_this_year?(date)
    date.month < @birth_date.month ||
    (date.month <= @birth_date.month &&
    date.day < @birth_date.day)
  end
end
