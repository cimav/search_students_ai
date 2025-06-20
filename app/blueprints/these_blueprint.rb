# app/blueprints/these_blueprint.rb
class TheseBlueprint < Blueprinter::Base
  fields :id, :title, :defence_date, :status

  field :status_name
end