class These < ApplicationRecord

  belongs_to :student

  STATUS = {
    'C' => "Concluida",
    'P' => "En progreso",
    'I' => "Inactiva"
  }

  def status_name
    STATUS[status]
  end

end

