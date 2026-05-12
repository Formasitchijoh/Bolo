class DashboardController < ApplicationController
  before_action :require_login

  def index
    case current_user.role
    when "customer"
      customer        = current_user.customer
      @total_jobs     = customer&.jobs&.count || 0
      @active_jobs    = customer&.jobs&.where(status: %w[available in_progress])&.count || 0
      @completed_jobs = customer&.jobs&.where(status: "completed")&.count || 0
    when "technician"
      technician             = current_user.technician
      @total_assignments     = technician&.assignments&.count || 0
      @pending_assignments   = technician&.assignments&.where(status: "pending")&.count || 0
      @active_assignments    = technician&.assignments&.where(status: "assigned")&.count || 0
      @completed_work_orders = technician&.work_orders&.where(status: "completed")&.count || 0
    end

    render current_user.role
  end
end
