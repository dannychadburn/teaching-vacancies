require_relative "../classification/runner"
require_relative "../classification/main_job_role_classifier"

namespace :classify do
  task main_job_role: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (1.year.ago..))
                  .with_any_of_job_roles(Vacancy::MAIN_JOB_ROLES.keys)
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[teacher teaching_assistant leadership education_support sendco other],
      actual: ->(ex) { ex.main_job_role },
      prediction: ->(ex) { MainJobRoleClassifier.new(ex.job_title).main_job_role_basic },
      identifier: ->(ex) { ex.job_title },
      # Need to make sure not to reset additional job roles
      # fix: ->(ex, new_value) { ex.update(job_roles: (ex.job_roles - [ex.main_job_role]) + [new_value]) },
    ).call
  end
end
