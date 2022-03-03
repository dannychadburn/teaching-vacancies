class ContractTypeClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def contract_type
    if vacancy.job_title.match?(/maternity|paternity|parental/i)
      "parental_leave_cover"
    elsif vacancy.job_title.match?(/(fixed term)|month|contract|(^|[^A-Za-z])temp/i)
      "fixed_term"
    else
      "permanent"
    end
  end
end
