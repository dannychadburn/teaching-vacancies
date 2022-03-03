class WorkingPatternsClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def full_time
    if (vacancy.job_title.match?(/0\.\d|part[ -]?time|[^a-zA-Z]p\.?t[^\w]|breakfast|lunch|dinner|mid[ -]?day|hours|h\.?p\.?w/i) ||
      vacancy.salary.match?(/rata|[^\d]0\.\d|part[ -]?time|[^a-zA-Z]p\.?t[^\w]/i)) &&
       !vacancy.job_title.match?(/full[ -]?time/i)
      "not_full_time"
    else
      "full_time"
    end
  end
end
