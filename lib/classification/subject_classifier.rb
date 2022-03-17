class SubjectClassifier
  attr_reader :job_title

  def initialize(job_title)
    @job_title = job_title
  end

  def subject # rubocop:disable Metrics
    return "Mathematics" if job_title.match?(/maths/i)
    return "Computing" if job_title.match?(/comput|(^|[^a-z])i\.?(c\.?)?t\.?([^a-z]|$)/i)
    return "Media studies" if job_title.match?(/media/i)
    return "Business studies" if job_title.match?(/business/i)
    return "Social sciences" if job_title.match?(/social science/i)
    return "Design and technology" if job_title.match?(/(design( and)? technology)|([^a-z]|^)d&?t/i)
    return "Art and design" if job_title.match?(/([^a-z]|^)art/i)
    return "Physical education" if job_title.include?("PE") || job_title.include?("P.E")
    return "Food Technology" if job_title.match?(/food/i)
    return "Religious education" if job_title.include?("RE") || job_title.match?(/religio/i)

    SUBJECT_OPTIONS.map(&:first).each do |subject|
      return subject if job_title.downcase.include?(subject.downcase)
    end

    # return "KS1" if job_title.match?(/k\.?s\.? ?1|key stage 1/i)
    # return "KS2" if job_title.match?(/k\.?s\.? ?2|key stage 2/i)
    return "Primary" if job_title.match?(/(class teacher)|(classroom teacher)|primary/i)
    return "Design and technology" if job_title.match?(/technology/i)
    return "Languages" if job_title.include?("MFL") # Don't override specific languages

    "Unknown"
  end
end
