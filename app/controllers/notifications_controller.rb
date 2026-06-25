class NotificationsController < ApplicationController
	before_action :require_login

	def index
    @notification = Notification.where(user: current_user)
		puts "#{ @notification.inspect }"
	end

end