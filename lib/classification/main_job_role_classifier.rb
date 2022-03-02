class MainJobRoleClassifier
  attr_reader :job_title

  def initialize(job_title)
    @job_title = job_title
  end

  def main_job_role
    # Naive classifer that _always_ returns teacher
    "teacher"
  end
end
