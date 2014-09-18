module Collections
  class Collection
    class CollectionDelegator < SimpleDelegator
      def initialize(obj, klass)
        super(obj)
        @klass = klass
      end

      def method_missing(m, *args, &block)
        target = self.__getobj__
        begin
          @klass.new(target.respond_to?(m) ? target.__send__(m, *args, &block) : super(m, *args, &block))
        ensure
          $@.delete_if {|t| %r"\A#{Regexp.quote(__FILE__)}:#{__LINE__-2}:"o =~ t} if $@
        end
      end
    end

    include Enumerable
    extend Forwardable

    def_delegators :@collection, :empty?, :last
    
    def initialize(collection)
      @collection = collection
    end

    def items
      CollectionDelegator.new(@collection, self.class)
    end

    def each
      @collection.each do |item|
        yield item
      end
    end

    def to_a
      @collection
    end

    def +(other)
      converted = other.respond_to?(:to_a) ? other.to_a : other
      self.class.new(@collection + converted)
    end
  end
end
