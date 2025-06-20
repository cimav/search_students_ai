require "csv"

class Api::StudentsController < ApplicationController
  include Pagy::Backend

  def search

    students = Student.filtered(params)

    # Total global (sin filtros)
    total_students = Student.count

    # 📊 Paginación
    begin
      pagy, records = pagy(students, limit:(params[:per_page] || 100).to_i)
    rescue Pagy::OverflowError
      # Devuelve la última página disponible en vez de fallar
      last_page = Pagy.new(count: students.count, page: 1, limit:(params[:per_page] || 100).to_i).pages
      pagy, records = pagy(students, page: last_page, limit:(params[:per_page] || 100).to_i)
    end

    if records.size > 0
      puts "#{records.first.id} | #{records.last.id}"
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
         .includes(:program, :studies_plan, :area, :supervisor, :co_supervisor, :external_supervisor, :these, :country, term_students: :term)

    respond_to do |format|
      format.csv do
        send_data students.to_csv,
                  filename: "alumnos-filtrados-#{Time.zone.now.strftime("%Y%m%d-%H%M")}.csv",
                  type: "text/csv"
      end
    end
  end

end
