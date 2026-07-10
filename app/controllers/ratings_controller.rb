class RatingsController < ApplicationController
  before_action :require_login

  def index
  end

  def create
    # We want to return the specific job that the customer wants to rate
    @job = current_user.customer.jobs.find(params[:job_id])
    # Once we have the job we want to rate this job done by this technician
    @rating = Rating.new(rating_params.merge(job: @job, technician: @job.assignments.first.technician, customer: current_user.customer))

    if @rating.save
      redirect_to job_path(@job), notice: "Thank you for rating this job."
    else
      redirect_to job_path(@job), alert: @rating.errors.full_messages.to_sentence
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:star)
  end
end