require "csv"

class Api::StudentsController < ApplicationController
  include Pagy::Backend

  def search

    students = Student.filtered(params)

    # Total global (sin filtros); cambia poco, no hace falta contarlo en cada búsqueda
    total_students = Rails.cache.fetch("students/total_count", expires_in: 10.minutes) { Student.count }

    # 📊 Paginación
    per_page = (params[:per_page] || 100).to_i
    begin
      pagy, records = pagy(students, limit: per_page)
    rescue Pagy::OverflowError
      # Devuelve la última página disponible en vez de fallar
      last_page = Pagy.new(count: students.count, page: 1, limit: per_page).pages
      pagy, records = pagy(students, page: last_page, limit: per_page)
    end

    render json: {
      students: StudentBlueprint.render_as_hash(records),
      total_pages: pagy.pages,
      current_page: pagy.page,
      total_filtered: pagy.count,
      total_all: total_students
    }
  end

  def export

    students = Student.filtered(params)

    respond_to do |format|
      format.csv do
        send_data students.to_csv,
                  filename: "alumnos-filtrados-#{Time.zone.now.strftime("%Y%m%d-%H%M")}.csv",
                  type: "text/csv"
      end
    end
  end

end
