class KeyStageClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def early_years
    if vacancy.job_title.match?(/eyfs|early years/i) ||
       vacancy.job_advert.match?(/eyfs|early years/i) ||
       (vacancy.primary? && !vacancy.job_advert.match?(/(k\.?s\.?|(key stage)) ?[12]/i))
      "early_years"
    else
      "not_early_years"
    end
  end
end
