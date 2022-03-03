class SendReponsibilitiesClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def naive
    "no_send_responsibilities"
  end
end
