class Feedback < ApplicationRecord
  belongs_to :vacancy
  belongs_to :user

  validates :rating, presence: true

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      user&.oid,
      vacancy.id,
      vacancy.school.urn,
      rating,
      comment,
      created_at.to_s
    ]
  end
end
