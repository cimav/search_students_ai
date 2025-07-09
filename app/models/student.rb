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
  # no esta funcionando; necesita un preload
  #has_one :last_student_mobility, -> { order(id: :desc) }, class_name: "StudentMobility"

  belongs_to :supervisor, class_name: "Staff", foreign_key: "supervisor", optional: true
  belongs_to :co_supervisor, class_name: "Staff", foreign_key: "co_supervisor", optional: true
  belongs_to :external_supervisor, class_name: "Staff", foreign_key: "external_supervisor", optional: true

  belongs_to :country

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

  scope :filtered_by_term_range, ->(start_code, end_code) {
    start_val = normalize_code(start_code) if start_code.present?
    end_val   = normalize_code(end_code) if end_code.present?

    query = joins(:terms).where.not(terms: { code: nil })
                         .where("terms.code REGEXP ?", '^[0-9]{4}-[1-2]') # solo códigos válidos
                         .distinct

    if start_val
      query = query.where(<<~SQL, start_val)
      (CAST(SUBSTRING_INDEX(terms.code, '-', 1) AS UNSIGNED) * 10 +
       CAST(SUBSTRING_INDEX(terms.code, '-', -1) AS UNSIGNED)) >= ?
    SQL
    end

    if end_val
      query = query.where(<<~SQL, end_val)
      (CAST(SUBSTRING_INDEX(terms.code, '-', 1) AS UNSIGNED) * 10 +
       CAST(SUBSTRING_INDEX(terms.code, '-', -1) AS UNSIGNED)) <= ?
    SQL
    end

    query
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

    #"#{last_name.to_s.strip.titleize}, #{first_name.to_s.strip.titleize}"
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
  def all_term_codes_old
    @all_term_codes ||= term_students.includes(:term).map { |ts| ts.term&.code }.compact.join(", ")
  end

  def first_term_code_old
    @first_term_code ||= all_term_codes.split(",").first&.strip
  end

  def last_student_mobility_old
    student_mobilities.order(id: :desc).limit(1).first rescue nil
  end

  def self.normalize_code_old(code)
    # Normaliza '2021-2' → 20212
    #return nil unless code.is_a?(String) && code.match?(/^20\d{2}-[12]$/)
    #year, sem = code.split('-').map(&:to_i)
    #year * 10 + sem
  end

  def self.normalize_code(code)
    # Normaliza '2021-2' → 20212
    return nil unless code.is_a?(String) && code.match?(/^20\d{2}-[12]$/)
    year, sem = code.to_s.strip.split('-').map(&:to_i)
    year * 10 + sem
  rescue
    nil
  end

  def self.filtered(params)

    students = self
         .includes(:program, :area, :supervisor, :co_supervisor, :external_supervisor, :these, :studies_plan,
                    :country, :latest_student_mobility, term_students: :term)
         .references(:program, :area, :supervisor, :co_supervisor, :external_supervisor, :term_students, :term)

=begin
    # Consulta base con pre-carga de asociaciones principales
    students = includes(
      :program, :area, :supervisor, :co_supervisor, :external_supervisor,
      :these, :studies_plan, :country, :latest_student_mobility
    ).left_joins(:terms)  # Usamos left_joins para términos en lugar de includes
     .references(:program, :area, :supervisor, :co_supervisor, :external_supervisor)
=end

=begin
    students = self
                 .includes(:program, :area, :supervisor, :co_supervisor, :external_supervisor, :these, :studies_plan,
                           :country, :latest_student_mobility, term_students: :term)
                 .joins("LEFT JOIN term_students ON term_students.student_id = students.id")
                 .joins("LEFT JOIN terms ON terms.id = term_students.term_id")
                 .select("students.*,
           GROUP_CONCAT(terms.code ORDER BY terms.code SEPARATOR ', ') AS grouped_term_codes,
           SUBSTRING_INDEX(GROUP_CONCAT(terms.code ORDER BY terms.code SEPARATOR ', '), ',', 1) AS first_term_code")
                 .group("students.id")
                 .references(:program, :area, :supervisor, :co_supervisor, :external_supervisor)
=end

    # 🔍 Por nombre
    if params[:student].present?
      tokens = params[:student].downcase.strip.split
      tokens.each do |token|
        students = students.where(
          "LOWER(CONCAT_WS(' ', students.last_name, students.last_name2, students.first_name)) LIKE ?", "%#{token}%"
        )
      end
    end

    # 👤 Asesores
    if params[:advisor].present?
      tokens = params[:advisor].downcase.strip.split

      students = students.joins(
        "LEFT JOIN staffs AS s1 ON students.supervisor = s1.id
     LEFT JOIN staffs AS s2 ON students.co_supervisor = s2.id
     LEFT JOIN staffs AS s3 ON students.external_supervisor = s3.id"
      )

      tokens.each do |token|
        students = students.where(
          "LOWER(CONCAT_WS(' ', s1.first_name, s1.last_name)) LIKE :token OR
       LOWER(CONCAT_WS(' ', s2.first_name, s2.last_name)) LIKE :token OR
       LOWER(CONCAT_WS(' ', s3.first_name, s3.last_name)) LIKE :token",
          token: "%#{token}%"
        )
      end
    end

    # 🎓 Filtro por programas
    if params[:program_ids].present?
      students = students.where(program_id: params[:program_ids])
    end

    # 🏛 Filtro por áreas
    if params[:area_ids].present?
      students = students.where(area_id: params[:area_ids])
    end

    # Status
    if params[:status].present?
      students = students.where(status: params[:status])
    end

    # Campus
    if params[:campus].present?
      students = students.where(campus_id: params[:campus])
    end

    # Terms !
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
    email_cimav email_personal país cvu curp ine mobilidad_institucion mobilidad_inicio mobilidad_fin mobilidad_actividades
  ]

    CSV.generate(col_sep: "\t", headers: true) do |csv|
      csv << attributes

      find_each do |student|
        csv << [
          student.id,
          student.card,
          student.first_name,
          student.last_name,
          student.last_name2,
          student.date_of_birth&.strftime("%d/%m/%Y"),
          student.age,
          student.gender,
          student.program&.name,
          student.studies_plan&.code,
          student.campus_name,
          student.status_name,
          student.start_date,
          student.end_date,
          student.graduation_date,
          student.inactive_date,
          student.definitive_inactive_date,
          student.area&.name,
          student.supervisor&.full_name,
          student.co_supervisor&.full_name,
          student.external_supervisor&.full_name,
          student.all_term_codes, # term_students.map { |ts| ts.term&.code }.compact.join(", "),
          student.first_term_code,
          student.these&.title,
          student.these&.defence_date&.strftime("%d/%m/%Y"),
          student.these&.status_name,
          student.email_cimav,
          student.email,
          student.country&.name,
          student.cvu,
          student.curp,
          student.ife,
          student.last_student_mobility&.institution,
          student.last_student_mobility&.start_date&.strftime("%d/%m/%Y"),
          student.last_student_mobility&.end_date&.strftime("%d/%m/%Y"),
          student.last_student_mobility&.activities

        ]
      end
    end
  end
  #def full_name
  #  "#{first_name} #{paternal_name} #{maternal_name}".strip
  #end

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
