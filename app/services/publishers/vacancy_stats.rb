class Publishers::VacancyStats
  CACHE_DURATION = 6.hours
  TABLE_NAME = "vacancies_published".freeze

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def number_of_unique_views = query_single_field(:number_of_unique_vacancy_views)

  private

  attr_reader :vacancy

  def query_single_field(field)
    Rails.cache.fetch([field, vacancy.id], expires_in: CACHE_DURATION, skip_nil: true) do
      sql = <<~SQL
        SELECT #{field}
        FROM `#{Rails.configuration.big_query_dataset}.#{TABLE_NAME}`
        WHERE id="#{StringAnonymiser.new(vacancy.id)}"
        AND publish_on = "#{vacancy.publish_on.iso8601}"
      SQL

      big_query.query(sql).first&.fetch(field)
    end
  rescue StandardError => e
    # Stats are a nice-to-have, return `nil` instead of failing hard if we can't get them
    Rollbar.error(e)

    nil
  end

  def big_query
    @big_query ||= Google::Cloud::Bigquery.new
  end
end
