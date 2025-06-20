# app/blueprints/term_student_blueprint.rb
class TermStudentBlueprint < Blueprinter::Base
  field :id
  association :term, blueprint: TermBlueprint
end