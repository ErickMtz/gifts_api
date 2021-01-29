class RecipientsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(json: { error_message: exception.message }, status: :not_found)
  end
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render(json: { error_message: exception.message }, status: :unprocessable_entity)
  end

  def index
    school = School.eager_load(:recipients).find(params[:school_id])
    render json: school.recipients.to_json
  end

  def create
    recipient = Recipient.new(recipient_params)
    recipient.school_id = params[:school_id]
    recipient.save!
    render json: recipient.to_json
  end

  def update
    recipient.update!(recipient_params)
    render json: recipient.to_json
  end

  def destroy
    recipient.destroy
    render json: recipient.to_json
  end

private
  def recipient_params
    params.require(:recipient).permit([:name, :email, :address])
  end

  def recipient
    @recipient ||= Recipient.find_by!({ id: params[:id], school_id: params[:school_id] })
  end
end
