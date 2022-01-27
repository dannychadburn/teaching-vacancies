class TravelTimeApi
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  MATRIX_API_URL = "https://api.traveltimeapp.com/v4/time-filter".freeze
  ISOCHRONE_API_URL = "https://api.traveltimeapp.com/v4/time-map".freeze

  TravelDistance = Struct.new(:point, :travel_time, :distance, :fares)

  # Home: [51.5032978, -0.0737895]
  # SB: [51.4980299, -0.1300138]
  # Institut Francais: [51.4948838, -0.175206]

  # Takes an origin point, one or more destination points (both as arrays [lat,lon]), and a
  # transport mode
  # Returns `TravelDistande` from the origin point to each destination point as an array in the same
  # order as the original array of destinations.
  def self.matrix(origin, destinations, transport_mode: :public_transport)
    locations = ([origin] + destinations).map.with_index do |loc, i|
      {
        id: i.to_s,
        coords: { lat: loc.first, lng: loc.second },
      }
    end
    departure_search = {
      id: "distance-search", # we only do one search at a time so this can be anything
      departure_location_id: "0",
      arrival_location_ids: locations.map { |l| l[:id] } - ["0"],
      transportation: { type: transport_mode },
      departure_time: (Time.now.beginning_of_day + 8.hours).to_formatted_s(:iso8601), # Check departures at 8am (maybe change?)
      travel_time: 7199, # Ignore destinations 2+ hours away (API charges based on distance)
      properties: %w[travel_time distance], # fields to include
    }
    query = {
      locations: locations,
      departure_searches: [departure_search],
    }

    response = HTTParty.post(
      MATRIX_API_URL,
      body: query.to_json,
      headers: {
        "Content-Type" => "application/json",
        "X-Application-Id" => ENV.fetch("TRAVELTIME_APPLICATION_ID"),
        "X-Api-Key" => ENV.fetch("TRAVELTIME_API_KEY"),
      },
    )

    response["results"].first["locations"].sort_by { |r| r["id"].to_i }.map do |r|
      props = r["properties"].first
      point = destinations[r["id"].to_i - 1]

      TravelDistance.new(point, props["travel_time"], props["distance"])
    end
  end

  def self.isochrone(origin, travel_time: 30.minutes, transport_mode: :public_transport)
    # ...
  end

  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
