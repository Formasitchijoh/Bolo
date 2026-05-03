class Job < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :customer
  belongs_to :job_category
  has_one :address, as: :addressable, dependent: :destroy
  has_many :assignments, dependent: :destroy
  validates :details, presence: true
  validates [ :price_range_min, :price_range_max ], presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[available in_progress completed needs_rebroadcast cancelled] }
  validate :price_range_is_valid
  scope :for_company,  ->(company) { where(company_id: company.id) }

  private

  def price_range_is_valid
    return unless price_range_min.present? && price_range_max.present?
    if price_range_min >= price_range_max
      errors.add(:price_range_min, "must be less than max price")
    end
  end
end
