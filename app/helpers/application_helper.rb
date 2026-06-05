module ApplicationHelper
  STATUS_BADGE_MAP = {
    "pending"     => "badge-pending",
    "assigned"    => "badge-assigned",
    "en_route"    => "badge-en-route",
    "arrived"     => "badge-arrived",
    "in_progress" => "badge-progress",
    "on_hold"     => "badge-pending",
    "completed"   => "badge-completed",
    "incomplete"  => "badge-rejected",
    "rejected"    => "badge-rejected",
    "cancelled"   => "badge-cancelled",
    "verified"    => "badge-verified",
    "unverified"  => "badge-pending"
  }.freeze

  def status_badge(status)
    css = STATUS_BADGE_MAP.fetch(status.to_s, "badge-pending")
    content_tag(:span, status.to_s.humanize, class: "badge #{css}")
  end
end
