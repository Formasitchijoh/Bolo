class DashboardController < ApplicationController
  before_action :require_login

  def index
    case current_user.role
    when "customer"
      customer         = current_user.customer
      @active_jobs     = customer&.jobs&.where(status: %w[available in_progress])
                                  &.includes(:job_category, :assignments)
                                  &.order(created_at: :desc) || []
      @recent_jobs     = customer&.jobs&.where(status: "completed")
                                  &.includes(:job_category)
                                  &.order(updated_at: :desc)
                                  &.limit(3) || []
      @pending_quotes  = WorkOrder.joins(assignment: :job)
                                  .where(jobs: { customer_id: customer.id }, status: "quote_submitted")
                                  .includes(assignment: :job)
                                  .order(updated_at: :desc)
    when "technician"
      technician = current_user.technician

      technician&.assignments&.where(status: "pending")
               &.where("claim_window < ?", Time.current)
               &.update_all(status: "rejected")

      @pending_assignment = technician&.assignments&.where(status: "pending")
                                       &.unexpired
                                       &.includes(job: :job_category)
                                       &.order(created_at: :desc)&.first
      @active_assignment  = technician&.assignments&.where(status: %w[assigned en_route arrived])
                                       &.includes(job: :job_category)
                                       &.order(updated_at: :desc)&.first
    end

    render current_user.role
  end
end
