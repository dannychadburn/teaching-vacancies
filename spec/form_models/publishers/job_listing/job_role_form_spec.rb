require "rails_helper"

RSpec.describe Publishers::JobListing::JobRoleForm, type: :model do
  it { is_expected.to validate_presence_of(:main_job_role) }
end
