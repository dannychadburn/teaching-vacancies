require_relative "../classification/runner"
require_relative "../classification/main_job_role_classifier"

namespace :classify do
  task main_job_role: :environment do
    Runner.new(
      Vacancy.published.where("publish_on >= ?", "2021-07-01").find_each,
      labels: %w[teacher teaching_assistant leadership education_support sendco other],
      actual: ->(ex) { ex.main_job_role },
      prediction: ->(ex) { MainJobRoleClassifier.new(ex.job_title).main_job_role_with_other },
      identifier: ->(ex) { ex.job_title },
      # Need to make sure not to reset main job value
      # fix: ->(ex, new_value) { ex.update(job_roles: (ex.job_roles - [ex.main_job_role]) + [new_value]) },
    ).call
  end
end
