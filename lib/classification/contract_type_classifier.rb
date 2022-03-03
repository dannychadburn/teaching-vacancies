class ContractTypeClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def contract_type
    if vacancy.job_title.match?(/(fixed[ -]?term)|month|contract|f\.?t\.?c|(^|[^A-Za-z])temp/i) ||
       vacancy.job_advert.match?(/fixed[ -]?term|temporary (for|basis|until)|up to \d\d? (months|years?)|until the/i) ||
       vacancy.job_title.match?(/maternity|paternity|parental/i) ||
       vacancy.job_advert.match?(/(maternity|paternity|parental|to) cover/i)
      "not_permanent"
    else
      "permanent"
    end
  end
end
