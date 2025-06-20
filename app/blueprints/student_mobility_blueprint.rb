# app/blueprints/student_mobility_blueprint.rb
class StudentMobilityBlueprint < Blueprinter::Base
  fields :id, :institution, :start_date, :end_date, :activities, :status
end