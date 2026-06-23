class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true
  validates :title, presence: true
  validates :details, presence: true
  after_create :send_notification

  private

  def send_notification
    # Calling the deliver_later or deliver_now because the  notify only builds the mail object bubt does not send it
    # TODO: Change the delivery method to deliver_later when the Jobs and Queues are set up
    NotificationMailer.with(notification: self).notify.deliver_now
  end
end
