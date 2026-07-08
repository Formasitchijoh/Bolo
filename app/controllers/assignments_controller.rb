class AssignmentsController < ApplicationController
  before_action :require_login
  before_action :require_technician
  # Sample controller callbacks which will
  # Only be called for the listed actions in the array
  before_action :set_assignment, only: [ :accept, :reject, :en_route, :arrived ]

  def index
    # mailer = NotificationMailer.with(user: current_user.technician).send_email
    # mailer.deliver_now!
    @assignments = current_user.technician.assignments
                               .includes(job: :job_category)
                               .order(created_at: :desc)
  end

  def show
  end
  def accept
    if @assignment.status == "pending" && @assignment.claim_window > Time.current
      @assignment.update!(status: "assigned")
      # When a technician accepts a job then the customer gets notified of this
      Notification.new(user: @assignment.job.customer.user, notifiable: @assignment, title: 'Your Task has been Claimed', details: "Your job has been assigned to #{ current_user.technician.user.first_name } #{ current_user.technician.user.last_name }").save!
      redirect_to assignments_path, notice: "Job accepted. Head to work!"
    else
      redirect_to assignments_path, alert: "This assignment has expired or is no longer available."
    end
  end

  def reject
    @assignment.update!(status: "rejected")
    JobMatchingService.new(@assignment.job).call
    redirect_to assignments_path, notice: "Job passed to the next technician."
  end

  def en_route
    @assignment.update!(status: "en_route")
    redirect_to assignments_path
  end

  # TODO: Once the technician arrives at the job destination then you create a work order
  def arrived
    WorkOrder.transaction do
      @assignment.update!(status: "arrived")
      WorkOrder.new(assignment: @assignment, status: "arrived").save!
    end
    redirect_to assignments_path
  end

  private

  def set_assignment
    @assignment = current_user.technician.assignments.find(params[:id])
  end
end
