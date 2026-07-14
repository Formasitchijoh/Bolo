require "rails_helper"

RSpec.describe WorkOrder, type: :model do
  before { allow_any_instance_of(Job).to receive(:broadcast_to_technicians) }

  describe "validations" do
    it "is valid with a recognised status" do
      work_order = build(:work_order, status: "in_progress")
      expect(work_order).to be_valid
    end

    it "is invalid with an unrecognised status" do
      work_order = build(:work_order, status: "flying")
      expect(work_order).not_to be_valid
    end

    it "accepts every valid status" do
      valid_statuses = %w[on_hold en_route arrived in_progress completed cancelled
                          quote_submitted quote_approved quote_rejected]
      valid_statuses.each do |status|
        expect(build(:work_order, status: status)).to be_valid
      end
    end
  end

  describe "associations" do
    subject { build(:work_order) }

    it { expect(subject).to respond_to(:assignment) }
    it { expect(subject).to respond_to(:line_items) }
    it { expect(subject).to respond_to(:comments) }
  end

  describe "#actual_duration_seconds" do
    it "returns nil when started_at is missing" do
      work_order = WorkOrder.new(completed_at: Time.current, total_paused_seconds: 0)
      expect(work_order.actual_duration_seconds).to be_nil
    end

    it "returns nil when completed_at is missing" do
      work_order = WorkOrder.new(started_at: 1.hour.ago, total_paused_seconds: 0)
      expect(work_order.actual_duration_seconds).to be_nil
    end

    it "returns elapsed seconds between started_at and completed_at" do
      work_order = WorkOrder.new(
        started_at: 2.hours.ago,
        completed_at: Time.current,
        total_paused_seconds: 0
      )
      expect(work_order.actual_duration_seconds).to be_within(5).of(7200)
    end

    it "subtracts paused time from the total duration" do
      work_order = WorkOrder.new(
        started_at: 2.hours.ago,
        completed_at: Time.current,
        total_paused_seconds: 1800
      )
      expect(work_order.actual_duration_seconds).to be_within(5).of(5400)
    end
  end

  describe "#formatted_duration" do
    it "returns N/A when the work order has not started or completed" do
      work_order = WorkOrder.new(total_paused_seconds: 0)
      expect(work_order.formatted_duration).to eq("N/A")
    end

    it "returns minutes only when duration is under one hour" do
      work_order = WorkOrder.new(
        started_at: 45.minutes.ago,
        completed_at: Time.current,
        total_paused_seconds: 0
      )
      expect(work_order.formatted_duration).to eq("45m")
    end

    it "returns hours and minutes when duration is over one hour" do
      work_order = WorkOrder.new(
        started_at: 2.hours.ago + 30.minutes,
        completed_at: Time.current,
        total_paused_seconds: 0
      )
      expect(work_order.formatted_duration).to eq("1h 30m")
    end

    it "accounts for paused time in the formatted output" do
      work_order = WorkOrder.new(
        started_at: 2.hours.ago,
        completed_at: Time.current,
        total_paused_seconds: 3600
      )
      expect(work_order.formatted_duration).to eq("1h 0m")
    end
  end
end
