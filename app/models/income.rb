class Income
  include Mongoid::Document

  TYPES = %W(
  	alimony_and_maintenance
		american_indian_and_alaskan_native
		capital_gains
		dividend
		employer_funded_disability
		estate_trust
		farming_and_fishing
		foreign
		interest
		lump_sum_amount
		military
		net_self_employment
		other
		pension_retirement_benefits
		permanent_workers_compensation
		prizes_and_awards
		rental_and_royalty
		scholorship_payments
		social_security_benefit
		supplemental_security_income
		tax_exempt_interest
		unemployment_insurance
		wages_and_salaries
	)

  FREQUENCIES = %W(biweekly daily half_yearly monthly quarterly weekly yearly)

  field :amount_in_cents, type: Integer, default: 0
  field :income_type, type: String
  field :frequency, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :evidence_flag, type: Boolean, default: false	# Proof of income provided?
  field :reported_date, type: DateTime
  field :reported_by, type: String

  embedded_in :person, :inverse_of => :incomes
  embedded_in :household, :inverse_of => :total_income

  validates :amount_in_cents, presence: true, 
  														numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :income_type, presence: true, 
  												inclusion: { in: TYPES, message: "%{value} is not a valid income type" }
  validates :frequency, 	presence: true, 
 												 	inclusion: { in: FREQUENCIES, message: "%{value} is not a valid frequency" }
  validates :start_date, presence: true


  def amount_in_dollars=(dollars)
    self.amount_in_cents = Rational(dollars) * Rational(100)
  end

  def amount_in_dollars
    (Rational(amount_in_cents) / Rational(100)).to_f if amount_in_cents
  end

end
