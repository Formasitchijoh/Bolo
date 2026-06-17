class Assignment < ApplicationRecord
  belongs_to :technician
  belongs_to :job
  belongs_to :company, optional: true
  has_one :work_order, dependent: :destroy
  validates :status, inclusion: { in: %w[pending assigned rejected cancelled en_route arrived] }
  scope :for_company,  ->(company) { where(company_id: company.id) }
  scope :unexpired,    -> { where("claim_window > ?", Time.current) }

  def claim_window_expired?
    claim_window < Time.current
  end
end
