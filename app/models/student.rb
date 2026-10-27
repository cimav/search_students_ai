# app/models/student.rb
require "csv"
class Student < ApplicationRecord

  # con has_many # Rails reutiliza la misma instancia en memoria (si fue cargada con .includes(...)), no hace una copia real.
  # es decir, si varios students tiene el mismo term, solo existe una copia del term aunque diferentes students lo tengan su has_many
  # la clave aqui es usar el .include

  belongs_to :program
  belongs_to :area
  belongs_to :studies_plan

  has_one :these

  has_many :term_students
  has_many :terms, through: :term_students
  has_many :advances

  has_many :student_mobilities

  belongs_to :supervisor, class_name: "Staff", foreign_key: "supervisor", optional: true
  belongs_to :co_supervisor, class_name: "Staff", foreign_key: "co_supervisor", optional: true
  belongs_to :external_supervisor, class_name: "Staff", foreign_key: "external_supervisor", optional: true

  belongs_to :country
  belongs_to :state, optional: true
  belongs_to :previous_institution, class_name: "PreviousInstitution", foreign_key: "previous_institution", optional: true

  scope :filtered_by_term_bounds, ->(start_code, end_code) {
    start_val = normalize_code(start_code) if start_code.present?
    end_val   = normalize_code(end_code) if end_code.present?

    subquery = Term
                 .select("student_id,
             MIN(CAST(SUBSTRING_INDEX(code, '-', 1) AS UNSIGNED) * 10 +
                 CAST(SUBSTRING_INDEX(code, '-', -1) AS UNSIGNED)) AS first_code_int,
             MAX(CAST(SUBSTRING_INDEX(code, '-', 1) AS UNSIGNED) * 10 +
                 CAST(SUBSTRING_INDEX(code, '-', -1) AS UNSIGNED)) AS last_code_int")
                 .joins(:term_students)
                 .where("terms.code REGEXP ?", '^[0-9]{4}-[1-2]')
                 .group("term_students.student_id")

    query = joins("INNER JOIN (#{subquery.to_sql}) AS term_bounds ON term_bounds.student_id = students.id")

    if start_val
      query = query.where("term_bounds.first_code_int >= ?", start_val)
    end

    if end_val
      query = query.where("term_bounds.last_code_int <= ?", end_val)
    end

    query.distinct
  }

  has_many :ordered_terms, -> { order(:code) }, through: :term_students, source: :term
  has_one :latest_student_mobility, -> { order(id: :desc) }, class_name: "StudentMobility"

  DELETED   = 0
  ACTIVE    = 1
  GRADUATED = 2
  INACTIVE  = 3
  UNREGISTERED = 4
  FINISH = 5

  STATUS = {
    DELETED       => 'Registro Eliminado',
    ACTIVE        => 'Activo',
    FINISH        => 'Egresado no graduado',
    GRADUATED     => 'Graduado',
    INACTIVE      => 'Baja temporal',
    UNREGISTERED  => 'Baja definitiva'
  }

  def status_name
    STATUS[status] || "Desconocido"
  end

  CAMPUS = {
    1 => "Chihuahua",
    2 => "Monterrey",
    4 => "Durango"
  }

  def campus_name
    CAMPUS[campus_id]
  end

  def full_name
    [last_name, last_name2, first_name].compact.join(' ').split.map(&:titleize).join(' ')
  end

  def paternal_name
    extract_compound_name(last_name2.present? ? last_name : last_name, position: :first)
  end

  def maternal_name
    if last_name2.present?
      last_name2.to_s.strip.titleize
    else
      extract_compound_name(last_name, position: :second)
    end
  end

  def age
    begin
      today = Date.today
      birth_date = self.date_of_birth
      age = today.year - birth_date.year

      if (birth_date.month > today.month) || (birth_date.month == today.month && birth_date.day > today.day)
        age -= 1
      end

      age
    rescue
      age = nil
    end
    age
  end

  def all_term_codes
    return @all_term_codes if defined?(@all_term_codes)

    @all_term_codes = if self[:grouped_term_codes].present?
                        self[:grouped_term_codes]
                      else
                        ordered_terms.load # Carga la relación
                        ordered_terms.map(&:code).join(", ")
                      end
  end

  def first_term_code
    return @first_term_code if defined?(@first_term_code)

    @first_term_code = if self[:first_term_code].present?
                         self[:first_term_code]
                       else
                         all_term_codes.split(",").first&.strip
                       end
  end

  def last_student_mobility
    latest_student_mobility
  end
  def self.normalize_code(code)
    # Normaliza '2021-2' → 20212
    return nil unless code.is_a?(String) && code.match?(/^20\d{2}-[12]$/)
    year, sem = code.to_s.strip.split('-').map(&:to_i)
    year * 10 + sem
  rescue
    nil
  end

  scope :by_name, ->(text) {
    next if text.blank?

    text.downcase.strip.split.inject(all) do |rel, token|
      rel.where("LOWER(CONCAT_WS(' ', students.last_name, students.last_name2, students.first_name)) LIKE ?", "%#{token}%")
    end
  }

  scope :by_advisor, ->(text) {
    next if text.blank?

    base = joins(
      "LEFT JOIN staffs AS s1 ON students.supervisor = s1.id
       LEFT JOIN staffs AS s2 ON students.co_supervisor = s2.id
       LEFT JOIN staffs AS s3 ON students.external_supervisor = s3.id"
    )

    text.downcase.strip.split.inject(base) do |rel, token|
      rel.where(
        "LOWER(CONCAT_WS(' ', s1.first_name, s1.last_name)) LIKE :token OR
         LOWER(CONCAT_WS(' ', s2.first_name, s2.last_name)) LIKE :token OR
         LOWER(CONCAT_WS(' ', s3.first_name, s3.last_name)) LIKE :token",
        token: "%#{token}%"
      )
    end
  }

  scope :by_program, ->(ids) { where(program_id: ids) if ids.present? }
  scope :by_area,    ->(ids) { where(area_id: ids) if ids.present? }
  scope :by_status,  ->(status) { where(status: status) if status.present? }
  scope :by_campus,  ->(campus) { where(campus_id: campus) if campus.present? }

  def self.filtered(params)
    students = includes(:program, :area, :supervisor, :co_supervisor, :external_supervisor, :these, :studies_plan,
                        :country, :state, :previous_institution, :latest_student_mobility, term_students: :term)
               .references(:program, :area, :supervisor, :co_supervisor, :external_supervisor, :term_students, :term)
               .by_name(params[:student])
               .by_advisor(params[:advisor])
               .by_program(params[:program_ids])
               .by_area(params[:area_ids])
               .by_status(params[:status])
               .by_campus(params[:campus])

    if params[:term_start].present? || params[:term_final].present?
      students = students.filtered_by_term_bounds(params[:term_start], params[:term_final])
    end

    # Pre-cargamos los términos ordenados al final
    students.preload(:ordered_terms).distinct
  end

  def self.to_csv
    attributes = %w[
    id matrícula nombre apellido_paterno apellido_materno nacimiento edad género programa plan_estudios campus status
    inicio final graducacion inactivo definitiva area asesor co_asesor external_asesor semestres primer tesis fecha_defensa tesis_status
    email_cimav email_personal país estado ciudad cvu curp ine mobilidad_institucion mobilidad_inicio mobilidad_fin mobilidad_actividades
    institucion_previa tipo_grado_previo desc_grado_previo fecha_grado_previo
  ]

    date = ->(value) { value&.strftime("%d/%m/%Y") }

    CSV.generate(col_sep: "\t", headers: true) do |csv|
      csv << attributes

      find_each do |student|
        csv << [
          student.id,
          student.card,
          student.first_name,
          student.last_name,
          student.last_name2,
          date.(student.date_of_birth),
          student.age,
          student.gender,
          student.program&.name,
          student.studies_plan&.code,
          student.campus_name,
          student.status_name,
          date.(student.start_date),
          date.(student.end_date),
          date.(student.graduation_date),
          date.(student.inactive_date),
          date.(student.definitive_inactive_date),
          student.area&.name,
          student.supervisor&.full_name,
          student.co_supervisor&.full_name,
          student.external_supervisor&.full_name,
          student.all_term_codes,
          student.first_term_code,
          student.these&.title,
          date.(student.these&.defence_date),
          student.these&.status_name,
          student.email_cimav,
          student.email,
          student.country&.name,
          student.state&.name,
          student.city,
          student.cvu,
          student.curp,
          student.ife,
          student.last_student_mobility&.institution,
          date.(student.last_student_mobility&.start_date),
          date.(student.last_student_mobility&.end_date),
          student.last_student_mobility&.activities,
          student.previous_institution&.name,
          student.previous_degree_type,
          student.previous_degree_desc,
          date.(student.previous_degree_date)
        ]
      end
    end
  end
  private

  def extract_compound_name(name_string, position:)
    return "" if name_string.blank?

    words = name_string.strip.split

    particles = %w[de del la las los y]

    case position
    when :first
      if particles.include?(words[0].downcase) && words.length >= 2
        "#{words[0]} #{words[1]}".titleize
      else
        words[0].titleize
      end
    when :second
      if words.length >= 3 && particles.include?(words[1].downcase)
        "#{words[1]} #{words[2]}".titleize
      elsif words.length >= 2
        words[1].titleize
      else
        ""
      end
    end
  end

end
