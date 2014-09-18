module Collections
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
end
