require_relative "../classification/runner"
require_relative "../classification/main_job_role_classifier"

namespace :classify do
  task main_job_role: :environment do
    Runner.new(
      Vacancy.published.where("publish_on >= ?", "2022-02-28").limit(100).find_each,
      actual: ->(ex) { ex.main_job_role },
      prediction: ->(ex) { MainJobRoleClassifier.new(ex).main_job_role },
      identifier: ->(ex) { ex.job_title },
      # Need to make sure not to reset main job value
      fix: ->(ex, new_value) { ex.update(job_roles: (ex.job_roles - [ex.main_job_role]) + [new_value]) },
    ).call
  end
end
