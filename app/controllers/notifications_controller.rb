class NotificationsController < ApplicationController
	before_action :require_login

	def show
		@notification = Notification.where(user: current_user)
		puts "#{ @notification.inspect }"
	end

end