class Vacancies::ApplicationController < ApplicationController
  private

  def school
    @school ||= School.find_by(id: school_id)
  end

  def school_id
    params.permit![:school_id]
  end

  def save_vacancy_without_validation
    @job_specification_form.vacancy.send :set_slug
    @job_specification_form.vacancy.status = :draft
    @job_specification_form.vacancy.save(validate: false)
  end

  def session_vacancy_id
    session[:vacancy_attributes].present? ? session[:vacancy_attributes]['id'] : false
  end

  def store_vacancy_attributes(vacancy_attributes)
    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(vacancy_attributes)
  end

  def update_vacancy(attributes)
    vacancy = school.vacancies.find(session_vacancy_id)
    vacancy.update_attributes(attributes)
    vacancy
  end
end
