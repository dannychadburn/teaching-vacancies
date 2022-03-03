class SendResponsibilitiesClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def naive
    if vacancy.organisation && vacancy.organisation.gias_data["TypeOfEstablishment (name)"]
        &.match?(/special/i)
      "send_responsibilities"
    else
      "no_send_responsibilities"
    end
  end
end
