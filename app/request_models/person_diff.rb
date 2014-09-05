class PersonDiff
  AddressDiff = Struct.new(:before, :after)

  attr_reader :addresses_added, :addresses_removed, :addresses_changed

  def initialize(opts = {})
    @addresses_added = opts.fetch(:addresses_added) { [] }
    @addresses_removed = opts.fetch(:addresses_removed) { [] }
    @addresses_changed = opts.fetch(:addresses_changed) { [] }
  end
end
