# frozen_string_literal: true

class PreviousInstitution  < ApplicationRecord

  self.table_name = "institutions"

  has_many :students #, foreign_key: "previous_institution"

end
