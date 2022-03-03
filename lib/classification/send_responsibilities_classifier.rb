class SendResponsibilitiesClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def naive
    # if vacancy.organisation && vacancy.organisation.gias_data["TypeOfEstablishment (name)"]
    #     &.match?(/special/i)
    #   "send_responsibilities"
    if vacancy.job_title.match?(/special|(learning support)|therapist|autism/i) ||
       vacancy.job_title.match?(/SEN|S\.E\.N|LSA|LSSA/) ||
       vacancy.salary.match?(/SEN/) ||
       vacancy.job_advert.match?(/SEN|S\.E\.N/)
      "send_responsibilities"
    else
      "no_send_responsibilities"
    end
  end
end
