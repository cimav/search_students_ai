class TermStudent < ApplicationRecord
  belongs_to :term
  belongs_to :student
end
