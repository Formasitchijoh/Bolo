require "rails_helper"

RSpec.describe "Authentication", type: :system, js: true do
  let(:user) { create(:customer_user) }

  describe "login" do
    it "allows a user to log in with valid credentials" do
      visit login_path

      fill_in "Email", with: user.email
      fill_in "Password", with: "password123"
      click_button "Login"

      expect(page).to have_current_path(dashboard_path)
    end

    it "rejects invalid credentials" do
      visit login_path

      fill_in "Email", with: user.email
      fill_in "Password", with: "wrongpassword"
      click_button "Login"

      expect(page).to have_current_path(login_path)
    end

    it "allows a logged-in user to log out" do
      visit login_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "password123"
      click_button "Login"

      page.driver.browser.manage.window.resize_to(1400, 900)
      find(".sidebar-logout").click

      expect(page).to have_current_path(login_path)
    end
  end
end
