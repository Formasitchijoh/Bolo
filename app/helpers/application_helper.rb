module ApplicationHelper
  STATUS_BADGE_MAP = {
    "available"   => "badge-available",
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
    "unverified"  => "badge-pending",
    "quote_submitted" => "badge-pending",
    "quote_approved"  => "badge-completed",
    "quote_rejected"  => "badge-rejected"
  }.freeze

  def notification_path_for(notification)
    case notification.notifiable_type
    when "WorkOrder"
      work_order_details_path(notification.notifiable)
    when "Quote"
      work_order_details_path(notification.notifiable.work_order)
    when "Assignment"
      jobs_path(notification.notifiable.job)
    end
  end

  def status_badge(status)
    css = STATUS_BADGE_MAP.fetch(status.to_s, "badge-pending")
    content_tag(:span, status.to_s.humanize, class: "badge #{css}")
  end

  def field_error(object, attribute)
    return if object.nil? || object.errors[attribute].blank?
    content_tag(:span, object.errors[attribute].join(", "), class: "field-error")
  end
end
