class Publisher < ApplicationRecord
  has_many :emergency_login_keys
  has_many :feedbacks
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :organisation_publishers, dependent: :destroy
  has_many :organisations, through: :organisation_publishers
  has_many :publisher_preferences, dependent: :destroy
  has_many :vacancies

  accepts_nested_attributes_for :organisation_publishers

  encrypts :family_name, :given_name

  # remove this line after dropping unencrypted columns
  self.ignored_columns = %w[family_name given_name]

  devise :omniauthable, :timeoutable, omniauth_providers: %i[dfe]
  self.timeout_in = 60.minutes # Overrides default Devise configuration

  def vacancies_with_job_applications_submitted_yesterday
    vacancies.distinct
             .joins(:job_applications)
             .where("DATE(job_applications.submitted_at) = ? AND job_applications.status = ?", Date.yesterday, 1)
  end
end
