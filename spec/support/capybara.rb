require "capybara/rails"
require "capybara/rspec"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  driver.browser.manage.window.resize_to(1400, 900)
  driver
end

Capybara.javascript_driver = :headless_chrome
Capybara.default_max_wait_time = 5
