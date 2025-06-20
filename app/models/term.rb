class Term < ApplicationRecord
  has_many :term_students
  has_many :students, through: :term_students
end

