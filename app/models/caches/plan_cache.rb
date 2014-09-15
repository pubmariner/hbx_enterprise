module Caches
  class PlanCache 

    def initialize
      @carriers = Plan.all.inject({}) do |accum, c|
        accum[c.id] = c
        accum
      end
    end

    def lookup(m_id)
      @carriers[m_id]
    end
  end
end
