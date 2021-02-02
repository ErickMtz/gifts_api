class OrdersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(json: { error_message: exception.message }, status: :not_found)
  end
  rescue_from ActiveRecord::RecordInvalid, ActionController::ParameterMissing, Order::Invalid do |exception|
    render(json: { error_message: exception.message }, status: :unprocessable_entity)
  end
  rescue_from Order::Error do |exception|
    render(json: { error_message: exception.message }, status: :conflict)
  end

  before_action :doorkeeper_authorize!

  def index
    school = School.eager_load(:orders).find(params[:school_id])
    render json: school.orders.to_json
  end

  def create
    order = Order.new(order_params.slice(:send_email, :gifts))
    order.recipients = order_params[:recipients].map { |recipient_id| Recipient.find(recipient_id) }
    order.school_id = params[:school_id]
    order.status = 'ORDER_RECEIVED'
    order.save!
    render json: order.to_json
  end

  def update
    order.update!(order_params)
    render json: order.to_json
  end

  def ship
    order.ship
    render json: order.to_json
  end

  def cancel
    order.cancel
    render json: order.to_json
  end

private
  def order_params
    params.require(:order).permit(:send_email, {:recipients => []}, {:gifts => []})
  end

  def order
    @order ||= Order.find_by!(id: params[:id] || params[:order_id], school_id: params[:school_id])
  end
end