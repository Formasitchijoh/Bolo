class WorkOrdersController < ApplicationController
  before_action :require_login
  before_action :require_technician
  before_action :set_work_order, only: [ :show, :work_order_started, :work_order_completed ]

  def index
    @work_orders = current_user.technician.work_orders.order(created_at: :desc)
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

  private

  def work_order_params
    params.require(:work_order).permit(:status, notes: [], media: [])
  end

  def set_work_order
    @work_order = current_user.technician.work_orders.find(params[:id])
  end
end
