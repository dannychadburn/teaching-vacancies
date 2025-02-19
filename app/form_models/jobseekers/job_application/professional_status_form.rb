class Jobseekers::JobApplication::ProfessionalStatusForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[qualified_teacher_status qualified_teacher_status_year qualified_teacher_status_details statutory_induction_complete]
  end
  attr_accessor(*fields)

  validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track] }
  validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } },
                                            if: -> { qualified_teacher_status == "yes" }
  validates :statutory_induction_complete, inclusion: { in: %w[yes no] }
end
