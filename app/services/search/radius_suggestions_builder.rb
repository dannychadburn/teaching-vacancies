class Search::RadiusSuggestionsBuilder
  include DistanceHelper
  include VacanciesOptionsHelper

  attr_reader :radius, :radius_suggestions, :search_params

  def initialize(radius, search_params)
    @radius = radius.to_i
    @search_params = search_params
    get_radius_suggestions
  end

  def get_radius_suggestions
    radius_index = radius_options.find_index(radius)
    return if radius_index.nil?

    wider_radii = (1..5).map { |index| radius_options[radius_index + index] }
    wider_radii_counts = wider_radii&.map { |wider_radius|
      unless wider_radius.nil?
        [
          wider_radius,
          Search::Strategies::Algolia.new(search_params.merge(radius: convert_miles_to_metres(wider_radius))).total_count,
        ]
      end
    }&.reject(&:nil?)

    @radius_suggestions = wider_radii_counts&.uniq(&:last)&.reject { |array| array.last.zero? }
  end

  private

  def radius_options
    RADIUS_OPTIONS - [0]
  end
end
