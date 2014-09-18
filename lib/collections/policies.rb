module Collections
  class Policies
    include Enumerable
    extend Forwardable

    def_delegators :@collection, :empty?, :last

    def initialize(collection)
      @collection = collection
    end

    def covering_health
      bind.select { |p| p.coverage_type == 'health'}
    end

    def covering_dental
      bind.select { |p| p.coverage_type == 'dental'}
    end

    def currently_active
      bind.select { |p| p.currently_active? }
    end

    def future_active
      bind.select { |p| p.future_active? }
    end

    def is_or_will_be_active
      bind.select { |p| p.currently_active? || p.future_active? }
    end

    def overlaps_policy(policy)
      bind.select { |p| policies_overlap?(policy, p) }
    end

    def each
      @collection.each do |item|
        yield item
      end
    end

    def sort_by_start_date
      bind.sort_by { |pol| pol.policy_start }
    end

    def most_recent
      self.sort_by_start_date.last
    end

    def +(other)
      converted = other.respond_to?(:to_a) ? other.to_a : other
      return_collection(@collection + converted)
    end

    def to_a
      @collection
    end

    def bind
      CollectionDelegator.new(@collection, self.class)
    end
    
    private

    def return_collection(collection)
      Collections::Policies.new(collection)
    end

    def policies_overlap?(a, b)
      first, second = Collections::Policies.new([a,b]).sort_by_start_date.to_a
      return true if first.policy_end.nil?
      (first.policy_end > second.policy_start)
    end
  end
end
