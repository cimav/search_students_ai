class Api::FiltersController < ApplicationController
  def index
    programs = Program.select(:id, :prefix, :name).order(:name)
    areas = Area.select(:id, :name).order(:name)

    render json: {
      programs: programs,
      areas: areas
    }
  end
end
