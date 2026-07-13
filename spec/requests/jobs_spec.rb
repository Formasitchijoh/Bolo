require "rails_helper"

RSpec.describe "Jobs", type: :request do
  before { allow_any_instance_of(Job).to receive(:broadcast_to_technicians) }

  let(:customer_user)    { create(:customer_user) }
  let(:technician_user)  { create(:technician_user) }
  let(:category)         { create(:job_category) }
  let(:job)              { create(:job, customer: customer_user.customer, job_category: category) }

  def sign_in(user)
    post login_path, params: { email: user.email, password: "password123" }
  end

  describe "GET /jobs" do
    context "when not logged in" do
      it "redirects to login" do
        get jobs_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as a customer" do
      it "returns 200" do
        sign_in(customer_user)
        get jobs_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when logged in as a technician" do
      it "redirects to dashboard" do
        sign_in(technician_user)
        get jobs_path
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "GET /jobs/:id" do
    context "when not logged in" do
      it "redirects to login" do
        get job_path(job)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as the job owner" do
      it "returns 200" do
        sign_in(customer_user)
        get job_path(job)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when logged in as a different customer (IDOR attempt)" do
      it "does not return a successful response" do
        other_customer = create(:customer_user)
        sign_in(other_customer)
        get job_path(job)
        expect(response).not_to have_http_status(:ok)
      end
    end
  end

  describe "POST /jobs" do
    let(:valid_params) do
      {
        job: {
          title: "Fix electrical wiring",
          details: "The living room has a short circuit.",
          price_range_min: 10000,
          price_range_max: 50000,
          job_category_id: category.id,
          latitude: 3.848,
          longitude: 11.502
        },
        address: "Yaoundé, Cameroon",
        latitude: 3.848,
        longitude: 11.502
      }
    end

    context "when not logged in" do
      it "redirects to login" do
        post jobs_path, params: valid_params
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as a customer" do
      before { sign_in(customer_user) }

      it "creates a job and redirects to jobs list" do
        expect {
          post jobs_path, params: valid_params
        }.to change(Job, :count).by(1)
        expect(response).to redirect_to(jobs_path)
      end

      it "does not create a job with invalid params" do
        expect {
          post jobs_path, params: { job: { title: "" } }
        }.not_to change(Job, :count)
      end
    end

    context "when logged in as a technician" do
      it "redirects to dashboard without creating a job" do
        sign_in(technician_user)
        expect {
          post jobs_path, params: valid_params
        }.not_to change(Job, :count)
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
