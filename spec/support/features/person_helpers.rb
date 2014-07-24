module Features
  def create_many_people(count)
    people = []
    3.times do
      people << create(:person)
    end
    people
  end
end
