class CommentsController < ApplicationController
  before_action :require_login

  def index
    @comments = Comment.where(commentable_type: params[:commentable_type], commentable_id: params[:commentable_id])
  end

  def new
    @comment = Comment.new
  end

  def create
    if params["job_id"]
      if current_user.customer?
        @commentable = current_user.customer.jobs.find(params["job_id"])
      elsif current_user.technician?
        @commentable = Job.joins(:assignments).where(assignments: { technician_id: current_user.technician.id }).find(params["job_id"])
      end
      @comment = Comment.new(user: current_user, commentable: @commentable, **comment_params)
      if @comment.save
        redirect_to job_path(@commentable), notice: "Comment added."
      else
        redirect_to job_path(@commentable), alert: @comment.errors.full_messages.to_sentence
      end
    elsif params["work_order_id"]
      if current_user.technician?
        @commentable = current_user.technician.work_orders.find(params["work_order_id"])
      elsif current_user.customer?
        @commentable = WorkOrder.joins(assignment: :job).where(jobs: { customer_id: current_user.customer.id }).find(params["work_order_id"])
      end
      @comment = Comment.new(user: current_user, commentable: @commentable, **comment_params)
      if @comment.save
        redirect_to work_order_details_path(@commentable), notice: "Comment added."
      else
        redirect_to work_order_details_path(@commentable), alert: @comment.errors.full_messages.to_sentence
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:body, media: [])
  end
end
