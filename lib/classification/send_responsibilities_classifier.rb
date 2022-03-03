class SendResponsibilitiesClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def naive
    if vacancy.job_title.match?(/special|(learning support)|therapist|autism/i) ||
       vacancy.job_title.match?(/SEN|S\.E\.N|SEMH|LSA|LSSA/) ||
       vacancy.salary.match?(/SEN/) ||
       vacancy.job_advert.match?(/SEN|S\.E\.N/) ||
       (vacancy.organisation && vacancy.organisation.gias_data["TypeOfEstablishment (name)"]&.match?(/special|(alternative provision)/i))
      "send_responsibilities"
    else
      "no_send_responsibilities"
    end
  end
end
