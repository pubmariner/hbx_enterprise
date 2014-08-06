class Ager
  def initialize(birth_date)
    @birth_date = birth_date
  end

  def age_as_of(date)
    age = date.year - @birth_date.year
    if before_birthday_this_year?(date)
      age -= 1 
    end
    age
  end

  private

  def before_birthday_this_year?(date)
    date.yday < @birth_date.yday
  end
end
