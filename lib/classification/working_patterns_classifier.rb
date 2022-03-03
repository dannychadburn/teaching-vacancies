class WorkingPatternsClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def full_time
    if vacancy.job_title.match?(/0\.\d|part[ -]?time|[^a-zA-Z]p\.?t[^\w]/i) ||
       vacancy.job_title.include?("FTE")
      "not_full_time"
    else
      "full_time"
    end
  end
end
