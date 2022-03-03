class KeyStageClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def early_years
    if vacancy.job_title.match?(/eyfs|early years/i) ||
       vacancy.job_advert.match?(/eyfs|early years/i) ||
       vacancy.primary?
      "early_years"
    else
      "not_early_years"
    end
  end
end
