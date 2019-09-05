class VacanciesController < ApplicationController
  include ParameterSanitiser

  PERMITTED_SEARCH_PARAMS = [phases: []]
                            .concat(VacancyFilters::AVAILABLE_FILTERS)
                            .uniq
                            .freeze
  DEFAULT_RADIUS = 20

  helper_method :location,
                :subject,
                :job_title,
                :minimum_salary,
                :working_pattern,
                :phases,
                :specific_phases?,
                :newly_qualified_teacher,
                :radius,
                :sort_column,
                :sort_order

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def index
    redirect_with_sort(:expires_on, :asc) && return if params[:jobs_sort] == 'sort_by_earliest_closing_date'
    redirect_with_sort(:expires_on, :desc) && return if params[:jobs_sort] == 'sort_by_furthest_closing_date'
    redirect_with_sort(:publish_on, :asc) && return if params[:jobs_sort] == 'sort_by_most_ancient'
    redirect_with_sort(:publish_on, :desc) && return if params[:jobs_sort] == 'sort_by_most_recent'

    @filters = VacancyFilters.new(search_params.to_hash)

    @sort = VacancySort.new(
      default_column: 'publish_on',
      default_order: 'desc'
    ).update(column: sort_column, order: sort_order)

    @vacancies = VacanciesFinder.new(@filters, @sort, page_number).vacancies
    AuditSearchEventJob.perform_later(audit_row) if valid_search?
    expires_in 5.minutes, public: true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(id)

      return render '/errors/trashed_vacancy_found', status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @vacancy = VacancyPresenter.new(vacancy)

    VacancyPageView.new(vacancy).track unless authenticated? || smoke_test?

    expires_in 5.minutes, public: true
  end

  def params
    @params ||= ParameterSanitiser.call(super)
  end

  private

  def redirect_with_sort(sort_column, sort_order)
    redirect_to jobs_path(params: search_params.merge(sort_column: sort_column, sort_order: sort_order))
  end

  def search_params
    params.permit(*PERMITTED_SEARCH_PARAMS)
  end

  def old_vacancy_path?(vacancy)
    request.path != job_path(vacancy) && !request.format.json?
  end

  def id
    params[:id]
  end

  def page_number
    return Vacancy.page.total_pages if Vacancy.page(params[:page]).out_of_range?

    params[:page]
  end

  def location
    params[:location]
  end

  def subject
    params[:subject]
  end

  def job_title
    params[:job_title]
  end

  def minimum_salary
    params[:minimum_salary]
  end

  def working_pattern
    params[:working_pattern]
  end

  def phases_to_a
    raw_phases = params[:phases]
    parsed_phases = JSON.parse(raw_phases) if raw_phases.present?
    parsed_phases.is_a?(Array) ? parsed_phases : []
  rescue JSON::ParserError
    []
  end

  def phases
    phases_to_a
  end

  def newly_qualified_teacher
    params[:newly_qualified_teacher]
  end

  def radius
    params[:radius] || DEFAULT_RADIUS
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end

  def specific_phases?
    return false if phases_to_a.blank?

    phases_to_a.reject(&:blank?).any?
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
  end

  def smoke_test?
    cookies[:smoke_test] != nil
  end

  def valid_search?
    @filters.any? && !smoke_test?
  end

  def audit_row
    { total_count: @vacancies.total_count }.merge(@filters.audit_hash)
  end
end
