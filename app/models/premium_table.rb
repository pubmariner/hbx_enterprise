class PremiumTable
  include Mongoid::Document

	field :rate_start_date, type: Date
	field :rate_end_date, type: Date
	field :age, type: Integer
	field :amount, type: BigDecimal, default: 0.0

	embedded_in :plan
end
