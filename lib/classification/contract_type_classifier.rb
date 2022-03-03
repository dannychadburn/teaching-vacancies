class ContractTypeClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def contract_type
    "permanent"
  end
end
