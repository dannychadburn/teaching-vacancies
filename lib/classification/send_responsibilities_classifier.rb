class SendResponsibilitiesClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def naive
    if vacancy.job_title.match?(/special\s|(learning support)|therapist|autism/i) ||
       vacancy.job_title.match?(/SEN|S\.E\.N|SEMH|LSA|LSSA/) ||
       vacancy.salary.include?("SEN") ||
       (vacancy.organisation && vacancy.organisation.gias_data["TypeOfEstablishment (name)"]&.match?(/special/i))
      "send_responsibilities"
    else
      "no_send_responsibilities"
    end
  end
end
