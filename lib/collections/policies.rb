module Collections
  class Policies
    include Enumerable
    extend Forwardable

    def_delegators :@collection, :empty?, :last

    def initialize(collection)
      @collection = collection
    end

    def covering_health
      result = @collection.select { |p| p.coverage_type == 'health'}
      return_collection(result)
    end

    def covering_dental
      result = @collection.select { |p| p.coverage_type == 'dental'}
      return_collection(result)
    end

    def currently_active
      result = @collection.select { |p| p.currently_active? }
      return_collection(result)
    end

    def future_active
      result = @collection.select { |p| p.future_active? }
      return_collection(result)
    end

    def is_or_will_be_active
      result = @collection.select { |p| p.currently_active? || p.future_active? }
      return_collection(result)
    end

    def overlaps_policy(policy)
      result = @collection.select { |p| policies_overlap?(policy, p) }
      return_collection(result)
    end

    def each
      @collection.each do |item|
        yield item
      end
    end

    def sort_by_start_date
      result = @collection.sort_by { |pol| pol.policy_start }
      return_collection(result)
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
