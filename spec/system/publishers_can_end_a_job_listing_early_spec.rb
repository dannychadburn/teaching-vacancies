require "rails_helper"

RSpec.describe "Publishers can end a job listing early" do
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_jobs_path
  end

  it "submits form, renders error, then ends listing early" do
    click_on vacancy.job_title
    click_on I18n.t("buttons.end_listing_early")
    click_on I18n.t("buttons.end_listing")

    expect(page).to have_content("There is a problem")

    choose I18n.t("helpers.label.publishers_job_listing_end_listing_form.end_listing_reason_options.suitable_candidate_found")
    select "Teaching Vacancies"

    expect { click_on I18n.t("buttons.end_listing") }.to change { Vacancy.live.count }.from(1).to(0)

    expect(current_path).to eq(jobs_with_type_organisation_path(:expired))
  end

  context "when there are draft applications for the listing" do
    let(:job) { double("Send Job Listing Ended Early Notification Job") }
    let(:jobseeker) { create(:jobseeker) }
    let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

    before { allow(SendJobListingEndedEarlyNotificationJob).to receive(:new) { job } }

    it "sends an email to jobseekers with draft applications" do
      click_on vacancy.job_title
      click_on I18n.t("buttons.end_listing_early")
      choose I18n.t("helpers.label.publishers_job_listing_end_listing_form.end_listing_reason_options.suitable_candidate_found")
      select "Teaching Vacancies"

      expect(job).to receive(:perform).with(vacancy)

      click_on I18n.t("buttons.end_listing")
    end
  end
end
