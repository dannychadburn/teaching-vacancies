class EctSuitableClassifier
  attr_reader :vacancy

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def naive
    if vacancy.job_roles.include?("teacher") && !vacancy.job_title.match?(/lead|head|second|cover/i)
      return "ect_suitable"
    end

    "not_ect_suitable"
  end

  # rubocop:disable Lint/DuplicateBranch
  def smarter
    if vacancy.job_title.match?(/lead|head|second|cover/i)
      "not_ect_suitable"
    elsif !vacancy.job_roles.include?("teacher")
      "not_ect_suitable"
    elsif vacancy.job_advert.match?(/experienced/i) && !vacancy.job_advert.match?(/nqt|n\.q\.t|ect|e\.c\.t|(early career)|(newly qualified)/i)
      "not_ect_suitable"
    elsif vacancy.salary.match?(/tlr|t\.l\.r|upper|ups|u\.p\.s/i) &&
          !vacancy.salary.match?(/mps|m\.p\.s|main|m\d/i)
      "not_ect_suitable"
    else
      "ect_suitable"
    end
  end
  # rubocop:enable Lint/DuplicateBranch
end
