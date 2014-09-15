module Caches
  class KeyCache 

    def initialize(kls)
      @records = kls.all.inject({}) do |accum, c|
        accum[c.id] = c
        accum
      end
    end

    def lookup(m_id)
      @records[m_id]
    end
  end
end
