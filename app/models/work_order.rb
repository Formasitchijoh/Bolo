class WorkOrder < ApplicationRecord
  belongs_to :assignment
  has_many :quotes, dependent: :destroy
  has_one :rating, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many_attached :media
  validates :status, inclusion: { in: %w[on_hold en_route arrived in_progress onhold incomplete completed cancelled quote_submitted quote_approved quote_rejected] }

  def actual_duration_seconds
    return nil unless started_at && completed_at
    (completed_at - started_at).to_i - total_paused_seconds
  end

  def formatted_duration
    total = actual_duration_seconds
    return "N/A" unless total

    hours   = total / 3600
    minutes = (total % 3600) / 60

    hours > 0 ? "#{hours}h #{minutes}m" : "#{minutes}m"
  end
end
