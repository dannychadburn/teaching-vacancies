require_relative "../classification/runner"
require_relative "../classification/ect_suitable_classifier"
require_relative "../classification/main_job_role_classifier"

namespace :classify do # rubocop:disable Metrics
  task main_job_role: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (1.year.ago..))
                  .with_any_of_job_roles(Vacancy::MAIN_JOB_ROLES.keys)
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[teacher teaching_assistant leadership education_support sendco],
      actual: ->(e) { e.main_job_role },
      prediction: ->(e) { MainJobRoleClassifier.new(e.job_title).main_job_role_basic },
      identifier: ->(e) { e.job_title },
      # Need to make sure not to reset additional job roles
      # fix: ->(e, new_value) { e.update(job_roles: (e.job_roles - [e.main_job_role]) + [new_value]) },
    ).call
  end

  task ect_suitable: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (1.year.ago..))
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[ect_suitable not_ect_suitable],
      actual: ->(e) { e.job_roles.include?("ect_suitable") ? "ect_suitable" : "not_ect_suitable" },
      prediction: ->(e) { EctSuitableClassifier.new(e).smarter },
      identifier: ->(e) { "#{e.job_title} (main role: #{e.main_job_role})\n    Salary: '#{e.salary}'" },
    ).call
  end
end
