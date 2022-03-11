class SubjectClassifier
  attr_reader :job_title

  def initialize(job_title)
    @job_title = job_title
  end

  def subject # rubocop:disable Metrics
    return "Mathematics" if job_title.match?(/maths/i)
    return "Media studies" if job_title.match?(/media/i)
    return "Business studies" if job_title.match?(/business/i)
    return "Computing" if job_title.match?(/computer/i)
    return "Social sciences" if job_title.match?(/social science/i)
    return "Design and technology" if job_title.match?(/(design( and)? technology)|[^a-z]d&?t/i)
    return "Art and design" if job_title.match?(/[^a-z]art/i)
    return "Physical education" if job_title.include?("PE")
    return "Early years" if job_title.include?("EYFS")
    return "Religious education" if job_title.include?("RE") || job_title.match?(/religio/i)

    SUBJECT_OPTIONS.map(&:first).each do |subject|
      return subject if job_title.downcase.include?(subject.downcase)
    end

    return "Primary" if job_title.match?(/(class teacher)|(classroom teacher)|primary|ks\d|key stage \d/i)
    return "Languages" if job_title.include?("MFL") # Don't override specific languages

    "Unknown"
  end
end
