class SchoolsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(json: { error_message: exception.message }, status: :not_found)
  end
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render(json: { error_message: exception.message }, status: :unprocessable_entity)
  end

  def create
    school = School.new(school_params)
    school.save!
    render json: school.to_json
  end

  def update
    school.update!(school_params)
    render json: school.to_json
  end

  def destroy
    school.destroy
    render json: school.to_json
  end

private
  def school_params
    params.require(:school).permit(:name)
  end

  def school
    @school ||= School.find(params[:id])
  end
end