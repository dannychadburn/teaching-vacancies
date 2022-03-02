require_relative "../classification/runner"
require_relative "../classification/main_job_role_classifier"

namespace :classify do
  task main_job_role: :environment do
    Runner.new(
      Vacancy.published.where("publish_on >= ?", "2022-01-01").limit(100),
      actual: ->(ex) { ex.main_job_role },
      prediction: ->(ex) { MainJobRoleClassifier.new(ex).main_job_role },
      identifier: ->(ex) { ex.job_title },
    ).call
  end
end
