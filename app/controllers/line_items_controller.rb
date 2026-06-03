class LineItemsController < ApplicationController
  before_action :require_login
  before_action :require_technician
  # Always important to set the model you are about to use
  before_action :set_work_order

  def index
    @line_items = @work_order.line_items
  end
  def new
    @line_item = LineItem.new
  end

  def create
    @line_item = @work_order.line_items.new(line_items_params)

    if @line_item.save
      redirect_to work_order_details_path(@work_order), notice: "Line item added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @line_item = @work_order.line_items.find(params[:id])
    @line_item.destroy!
    redirect_to work_order_details_path(@work_order), notice: "Line item removed."
  end

  private

  # IMPORTANT: Missed this on first try, I was concerned on how to get the work order to use so I wanted to pass it to the query params 
  # It did not come easy
  def set_work_order
    # This is important because for the current users session if it is a technician we want to
    # Querry the association between techncian and workorder and return all workorders that this technician started
    #  and which matches this exact work_order_id we have from our params
    @work_order = current_user.technician.work_orders.find(params[:work_order_id])
  end

  def line_items_params
    params.require(:line_item).permit(:description, :amount)
  end
end
