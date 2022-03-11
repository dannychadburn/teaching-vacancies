class SubjectClassifier
  attr_reader :job_title

  def initialize(job_title)
    @job_title = job_title
  end

  def subject
    return "Mathematics" if job_title.match?(/maths/i)
    return "Physical education" if job_title.include?("PE")

    SUBJECT_OPTIONS.map(&:first).each do |subject|
      return subject if job_title.downcase.include?(subject.downcase)
    end

    "Unknown"
  end
end
