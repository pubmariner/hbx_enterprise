module Caches
  class MemberCache

    def initialize(member_ids = [])
      @people = Person.find_for_members(member_ids).unscoped
      @members = @people.inject({}) do |acc, per|
        per.members.each do |m|
          acc[m.hbx_member_id] = m
        end
        acc
      end
    end

    def lookup(m_id)
      @members[m_id]
    end
  end
end
