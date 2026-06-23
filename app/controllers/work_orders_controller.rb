class WorkOrdersController < ApplicationController
  before_action :require_login
  before_action :require_technician, only: [ :index, :work_order_started, :work_order_completed, :submit_quote, :hold, :resume ]
  before_action :set_work_order, only: [ :show, :work_order_started, :work_order_completed, :submit_quote, :approve_quote, :reject_quote, :hold, :resume ]

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
    # When a technician accepts a job then the customer gets notified of this
    Notification.new(user: @work_order.assignment.job.customer.user, notifiable: @work_order, title: 'Your Task has been Completed', details: "Your job has been Completed by #{ current_user.technician.user.first_name } #{ current_user.technician.user.last_name } ").save!
    redirect_to work_order_details_path(@work_order), notice: "Work order marked as complete."
  end

  def submit_quote
    @work_order.update!(status: "quote_submitted")
    # When a Quote is submitted then customer is informed of the details so they can approve or reject
    Notification.new(user: @work_order.assignment.job.customer.user, notifiable: @work_order, title: 'You have a Quote', details: "The technician #{ current_user.technician.user.first_name }  #{ current_user.technician.user.last_name } submitted a Quote waiting for your approval").save!
    redirect_to work_order_details_path(@work_order), notice: "Quote submitted to customer."
  end

  def approve_quote
    @work_order.update!(status: "quote_approved")
    Notification.new(user: @work_order.assignment.job.customer.user, notifiable: @work_order, title: 'Quote has been approved', details: "The Customer #{ @work_order.assignment.job.customer.user.first_name } #{ @work_order.assignment.job.customer.user.last_name } submitted a Quote waiting for your approval").save!
    redirect_to job_path(@work_order.assignment.job), notice: "Quote approved."
  end

  def reject_quote
    @work_order.update!(status: "quote_rejected")
    redirect_to job_path(@work_order.assignment.job), notice: "Quote rejected."
  end

  def hold
    @work_order.update!(status: "on_hold", paused_at: Time.current)
    redirect_to work_order_details_path(@work_order), notice: "Work paused."
  end

  def resume
    paused_duration =  @work_order.paused_at ? (Time.current - @work_order&.paused_at).to_i : 0
    @work_order.update!(
      status: "in_progress",
      paused_at: nil,
      total_paused_seconds: @work_order.total_paused_seconds + paused_duration
    )
    redirect_to work_order_details_path(@work_order), notice: "Work resumed."
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
