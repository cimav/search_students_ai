class StaffBlueprint < Blueprinter::Base
  fields :id, :first_name, :last_name
  field :short_name
  field :full_name
end
