# app/blueprints/student_blueprint.rb
class StudentBlueprint < Blueprinter::Base
  identifier :id

  fields :card, :first_name, :last_name, :last_name2, :status, :campus_id, :email, :email_cimav, :curp, :ife, :cvu,
         :gender, :date_of_birth, :start_date, :end_date, :graduation_date, :inactive_date, :definitive_inactive_date

  field :status_name
  field :campus_name

  field :full_name
  field :paternal_name
  field :maternal_name

  field :age
  field :last_student_mobility

  field :all_term_codes
  field :first_term_code

  association :program, blueprint: ProgramBlueprint
  association :area, blueprint: AreaBlueprint
  association :country, blueprint: CountryBlueprint
  association :term_students, blueprint: TermStudentBlueprint
  association :studies_plan, blueprint: StudiesPlanBlueprint
  association :these, blueprint: TheseBlueprint

  association :supervisor, blueprint: StaffBlueprint
  association :co_supervisor, blueprint: StaffBlueprint
  association :external_supervisor, blueprint: StaffBlueprint

end
