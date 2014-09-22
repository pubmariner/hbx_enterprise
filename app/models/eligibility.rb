class Eligibility
  include Mongoid::Document
  include Mongoid::Timestamps

	field :determination_date, type: Date
  field :magi, type: BigDecimal, default: 0.00  # Modified Adjusted Gross Income
  field :max_aptc, type: BigDecimal, default: 0.00
  field :csr_percent, type: BigDecimal, default: 0.00

  field :ia_eligible, type: Boolean
  field :medicaid_chip_eligible, type: Boolean


  field :tax_filing_status, type: String
  field :tax_filing_together, type: Boolean
  field :is_enrolled_for_res_coverage, type: Boolean
  field :is_without_assistance, type: Boolean
  field :years_to_renew_coverage, type: Integer
  field :financial_assistance, type: Boolean
  field :receiving_benefit, type: Boolean

  embedded_in :household

  validates_presence_of :date_determined, :max_aptc, :csr_percent
  validate :csr_as_percent

	# Validate csr_percent value is in range 1..0
  def csr_as_percent
		errors.add(:csr_percent, "value must be between 0 and 1") unless (0 <= csr_percent && csr_percent <= 1)
  end

end
