require "rails_helper"

RSpec.describe Job, type: :model do
  before { allow_any_instance_of(Job).to receive(:broadcast_to_technicians) }

  let(:customer) { create(:customer) }
  let(:category) { create(:job_category) }

  def valid_job(overrides = {})
    Job.new(
      customer: customer,
      job_category: category,
      title: "Fix leaking pipe",
      details: "Kitchen pipe has been leaking.",
      price_range_min: 5000,
      price_range_max: 15000,
      **overrides
    )
  end

  describe "validations" do
    it "is valid with all required fields" do
      expect(valid_job).to be_valid
    end

    it "requires a title" do
      expect(valid_job(title: nil)).not_to be_valid
    end

    it "requires details" do
      expect(valid_job(details: nil)).not_to be_valid
    end

    it "requires price_range_min" do
      expect(valid_job(price_range_min: nil)).not_to be_valid
    end

    it "requires price_range_max" do
      expect(valid_job(price_range_max: nil)).not_to be_valid
    end

    it "does not allow price_range_min to equal price_range_max" do
      expect(valid_job(price_range_min: 5000, price_range_max: 5000)).not_to be_valid
    end

    it "does not allow price_range_min to exceed price_range_max" do
      expect(valid_job(price_range_min: 20000, price_range_max: 10000)).not_to be_valid
    end

    it "does not allow negative price_range_min" do
      expect(valid_job(price_range_min: -1)).not_to be_valid
    end
  end

  describe "associations" do
    subject { create(:job, customer: customer, job_category: category) }

    it "belongs to a customer" do
      expect(subject.customer).to eq(customer)
    end

    it "belongs to a job category" do
      expect(subject.job_category).to eq(category)
    end

    it "has many assignments" do
      expect(subject).to respond_to(:assignments)
    end

    it "has many comments" do
      expect(subject).to respond_to(:comments)
    end

    it "has one rating" do
      expect(subject).to respond_to(:rating)
    end
  end
end
