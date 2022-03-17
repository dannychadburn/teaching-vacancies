require_relative "../classification/runner"
require_relative "../classification/contract_type_classifier"
require_relative "../classification/ect_suitable_classifier"
require_relative "../classification/key_stage_classifier"
require_relative "../classification/main_job_role_classifier"
require_relative "../classification/send_responsibilities_classifier"
require_relative "../classification/subject_classifier"
require_relative "../classification/working_patterns_classifier"

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

  task send_responsibilities: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (1.year.ago..))
                  .includes(:organisations)
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[send_responsibilities no_send_responsibilities],
      actual: ->(e) { e.job_roles.include?("send_responsible") || e.job_roles.include?("sendco") ? "send_responsibilities" : "no_send_responsibilities" },
      prediction: ->(e) { SendResponsibilitiesClassifier.new(e).naive },
      identifier: ->(e) { "#{e.job_title} (main role: #{e.main_job_role})" },
    ).call
  end

  task working_pattern_full_time: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (1.year.ago..))
                  .includes(:organisations)
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[full_time not_full_time],
      actual: ->(e) { e.working_patterns.include?("full_time") ? "full_time" : "not_full_time" },
      prediction: ->(e) { WorkingPatternsClassifier.new(e).full_time },
      identifier: ->(e) { "#{e.job_title} (main role: #{e.main_job_role})\n   Salary: #{e.salary}" },
    ).call
  end

  task contract_type: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (5.months.ago..))
                  .includes(:organisations)
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[permanent not_permanent],
      actual: ->(e) { e.contract_type == "permanent" ? "permanent" : "not_permanent" },
      prediction: ->(e) { ContractTypeClassifier.new(e).contract_type },
      identifier: ->(e) { "#{e.job_title} (main role: #{e.main_job_role})\n#{e.job_advert[0..500]}\n\n" },
    ).call
  end

  task ks_early_years: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (5.months.ago..))
                  .with_any_of_key_stages(%w[early_years ks1 ks2])
                  .includes(:organisations)
                  .find_each

    Runner.new(
      vacancies,
      labels: %w[early_years not_early_years],
      actual: ->(e) { e.key_stages.include?("early_years") ? "early_years" : "not_early_years" },
      prediction: ->(e) { KeyStageClassifier.new(e).early_years },
      identifier: ->(e) { "#{e.job_title} (main role: #{e.main_job_role})\n  -> Phase: #{e.phase}" },
    ).call
  end

  task subject: :environment do
    vacancies = Vacancy
                  .published
                  .where(publish_on: (6.months.ago..))
                  # Disregard zero or multi-subject vacancies
                  .where("cardinality(subjects) = 1")
                  # Disregard non-secondary vacancies where subjects make less sense
                  .where("readable_phases && ARRAY[?]::varchar[]", "secondary")
                  .with_any_of_job_roles("teacher")
                  .find_each

    Runner.new(
      vacancies,
      labels: SUBJECT_OPTIONS.map(&:first) + ["Unknown"],
      actual: ->(e) { e.subjects.first == "ICT" ? "Computing" : e.subjects.first },
      prediction: ->(e) { SubjectClassifier.new(e.job_title).subject },
      identifier: ->(e) { e.job_title },
    ).call
  end
end
