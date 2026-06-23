class NotificationMailer < ApplicationMailer
	default from: 'onboarding@resend.dev'

	def notify
		@notification = params[:notification]
		@user = @notification.user.email
		@url = 'http://127.0.0.1:3000/dashboard'
		mail(to: "formasitf@gmail.com", subject: @notification.title)
	end
end
