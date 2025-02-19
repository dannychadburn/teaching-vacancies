require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  let(:jobseeker) { create(:jobseeker) }
  let(:expected_data) do
    {
      email_identifier: anonymised_form_of(reported_email),
      success: successful_attempt?,
      errors: sign_in_errors,
    }
  end

  let(:reported_email) { nil }

  before do
    visit root_path
    within("nav") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_jobseeker")
  end

  context "when entering correct details" do
    let(:email) { jobseeker.email }
    let(:password) { jobseeker.password }
    let(:successful_attempt?) { "true" }
    let(:sign_in_errors) { nil }
    let(:reported_email) { email }

    it "signs in the jobseeker" do
      sign_in_jobseeker(email: email, password: password)
      expect(current_path).to eq(jobseeker_root_path)
    end

    it "triggers a successful `jobseeker_sign_in_attempt` event" do
      expect { sign_in_jobseeker(email: email, password: password) }
        .to have_triggered_event(:jobseeker_sign_in_attempt)
        .with_data(expected_data)
    end
  end

  context "when entering incorrect details" do
    let(:successful_attempt?) { "false" }
    let(:sign_in_errors) { anything }

    context "when details are missing" do
      let(:email) { "" }
      let(:password) { "" }

      it "does not sign in the jobseeker and displays an error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.failure.blank"))
      end

      it "triggers an unsuccessful `jobseeker_sign_in_attempt` event" do
        expect { sign_in_jobseeker(email: email, password: password) }
          .to have_triggered_event(:jobseeker_sign_in_attempt)
          .with_data(expected_data)
      end
    end

    context "when the account does not exist" do
      let(:email) { "fake@example.net" }
      let(:password) { jobseeker.password }

      it "does not sign in the jobseeker and displays a general error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end

      it "triggers an unsuccessful `jobseeker_sign_in_attempt` event" do
        expect { sign_in_jobseeker(email: email, password: password) }
          .to have_triggered_event(:jobseeker_sign_in_attempt)
          .with_data(expected_data)
      end
    end

    context "when the password is incorrect" do
      let(:email) { jobseeker.email }
      let(:password) { "incorrect_password" }

      it "does not sign in the jobseeker and displays a general error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end

      it "triggers an unsuccessful `jobseeker_sign_in_attempt` event" do
        expect { sign_in_jobseeker(email: email, password: password) }
          .to have_triggered_event(:jobseeker_sign_in_attempt)
          .with_data(expected_data)
      end
    end
  end

  context "when entering incorrect details followed by correct detail" do
    let(:email) { jobseeker.email }
    let(:password) { "incorrect_password" }

    it "signs in the jobseeker on the second attempt" do
      sign_in_jobseeker(email: email, password: password)
      sign_in_jobseeker(email: email, password: jobseeker.password)
      expect(current_path).to eq(jobseeker_root_path)
    end
  end
end
