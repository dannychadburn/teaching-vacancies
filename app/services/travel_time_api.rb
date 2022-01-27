class TravelTimeApi
  API_URL = "https://api.traveltimeapp.com/v4/time-filter".freeze

  def self.matrix(origin, destinations)
    # ...
  end

  def self.isochrone(origin, travel_time: 30.minutes, transport_mode: :public_transport)
    # ...
  end

  private

  def fetch_distances
    query = {
      locations: locations,
      departure_searches: [departure_search],
    }
    response = HTTParty.post(
      API_URL,
      body: query.to_json,
      headers: {
        "Content-Type" => "application/json",
        "X-Application-Id" => ENV.fetch("TRAVELTIME_APPLICATION_ID"),
        "X-Api-Key" => ENV.fetch("TRAVELTIME_API_KEY"),
      },
    )

    @results = response["results"].first["locations"].to_h { |r| [r["id"], r["properties"]] }
  end

  def locations
    @locations ||= @vacancies.map { |vacancy|
      {
        id: vacancy.id,
        coords: {
          lat: vacancy.geolocation.lat,
          lng: vacancy.geolocation.lon,
        },
      }
    } + [{
      id: "_user",
      coords: {
        lat: @origin_lat,
        lng: @origin_lon,
      },
    }]
  end

  def departure_search
    {
      id: "distance-search",
      departure_location_id: "_user",
      arrival_location_ids: @vacancies.map(&:id),
      transportation: { type: "public_transport" },
      departure_time: "2022-01-27T08:00:00Z",
      travel_time: 7200, # TODO: Change me
      properties: %w[travel_time distance],
    }
  end
end
