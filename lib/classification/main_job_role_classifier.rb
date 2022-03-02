class MainJobRoleClassifier
  attr_reader :job_title

  def initialize(job_title)
    @job_title = job_title
  end

  # rubocop:disable Metrics/MethodLength, Lint/DuplicateBranch
  def main_job_role
    case job_title
    when /PA/, /lunch|catering|kitchen|technician/i
      "other"
    when /[^a-zA-Z]TA/, /(teaching assistant)|hlta/i
      "teaching_assistant"
    when /(assistant head)|(head teacher)|(head of school)|director|principal|avp|ceo|coo|chief/i
      "leadership"
    when /senco|sendco/i
      "sendco"
    when /KS/, /(^|[^a-z])(teacher|lecturer|nqt|educator|practitioner|specialist|n\.q\.t|uqt|u\.q\.t|ect|e\.c\.t|graduate|(train to teach)|(head of)|lead|leader|(lead practitioner)|(second in)|2ic|2nd|(second for)|3rd|3ic|(third in)|(third for))/i
      "teacher"
    when %r{head|ordinat|aht|i/c|tlr|deputy|(subject driver)}i
      "leadership"
    when /assistant|intervention|mentor|support|1-2-1|(one to one)|1:1|learning|coach|emotion|advocate|psa|(small group)|lsa|hlta|tutor|instructor|lssa|(cover supervisor)/i
      "education_support"
    when Regexp.union(SUBJECT_OPTIONS.map(&:first))
      "teacher"
    else
      "other"
    end
  end
  # rubocop:enable Metrics/MethodLength, Lint/DuplicateBranch
end
