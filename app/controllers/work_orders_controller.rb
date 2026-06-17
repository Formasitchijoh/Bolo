class WorkOrdersController < ApplicationController
  before_action :require_login
  before_action :require_technician, only: [ :index, :show, :work_order_started, :work_order_completed, :submit_quote ]
  before_action :set_work_order, only: [ :show, :work_order_started, :work_order_completed, :submit_quote, :approve_quote, :reject_quote ]

  def index
    @work_orders = current_user.technician.work_orders
                               .includes(assignment: { job: [:customer] })
                               .order(created_at: :desc)
  end

  def show
  end

  def work_order_started
    @work_order.update!(status: "in_progress", started_at: Time.current)
    redirect_to work_order_details_path(@work_order)
  end

  def work_order_completed
    @work_order.update!(status: "completed", completed_at: Time.current)
    redirect_to work_order_details_path(@work_order), notice: "Work order marked as complete."
  end

  def submit_quote
    @work_order.update!(status: "quote_submitted")
    redirect_to work_order_details_path(@work_order), notice: "Quote submitted to customer."
  end

  def approve_quote
    @work_order.update!(status: "quote_approved")
    redirect_to job_path(@work_order.assignment.job), notice: "Quote approved."
  end

  def reject_quote
    @work_order.update!(status: "quote_rejected")
    redirect_to job_path(@work_order.assignment.job), notice: "Quote rejected."
  end

  private

  def set_work_order
    if current_user.technician?
      @work_order = current_user.technician.work_orders.find(params[:id])
    elsif current_user.customer?
      @work_order = WorkOrder.joins(assignment: :job)
                             .where(jobs: { customer_id: current_user.customer.id })
                             .find(params[:id])
    end
  end
end
