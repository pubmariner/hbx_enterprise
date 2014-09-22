class Eligibility
  include Mongoid::Document
  include Mongoid::Timestamps

	field :determination_date, type: Date
  field :magi_in_cents, type: Integer, default: 0  # Modified Adjusted Gross Income
  field :max_aptc_in_cents, type: Integer, default: 0
  field :csr_percent, type: BigDecimal, default: 0.00

  field :ia_eligible, type: Boolean
  field :medicaid_chip_eligible, type: Boolean


  field :tax_filing_status, type: String
  field :tax_filing_together, type: Boolean
  field :is_enrolled_for_res_coverage, type: Boolean
  field :is_without_assistance, type: Boolean
  field :max_renewal_year, type: Integer
  field :financial_assistance, type: Boolean
  field :receiving_benefit, type: Boolean

  embedded_in :household

  validates_presence_of :determination_date, :max_aptc_in_cents, :csr_percent
  validates_inclusion_of :max_renewal_year, :in => 2013..2030, message: "must fall between 2013 and 2030"
  validate :csr_as_percent

  def magi_in_dollars=(dollars)
    self.magi_in_cents = Rational(dollars) * Rational(100)
  end

  def magi_in_dollars
    (Rational(magi_in_cents) / Rational(100)).to_f if magi_in_cents
  end

  def max_aptc_in_dollars=(dollars)
    self.max_aptc_in_cents = Rational(dollars) * Rational(100)
  end

  def max_aptc_in_dollars
    (Rational(max_aptc_in_cents) / Rational(100)).to_f if max_aptc_in_cents
  end

private
	# Validate csr_percent value is in range 1..0
  def csr_as_percent
		errors.add(:csr_percent, "value must be between 0 and 1") unless (0 <= csr_percent && csr_percent <= 1)
  end

end
