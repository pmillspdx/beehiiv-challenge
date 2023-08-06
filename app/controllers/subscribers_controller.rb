# frozen_string_literal: true

class SubscribersController < ApplicationController
  include PaginationMethods

  ##
  # GET /api/subscribers
  def index
    total_records = Subscriber.count
    limited_subscribers = Subscriber.limit(limit).offset(offset)

    render json: {subscribers: limited_subscribers, pagination: pagination(total_records)}, formats: :json
  end

  ##
  # POST /api/subscribers
  def create
    subscriber = Subscriber.new(name: params[:name], email: params[:email], status: "active")
    subscriber.save!
    render json: {message: "Subscriber created successfully"}, formats: :json, status: :created
  rescue ActiveRecord::RecordInvalid => error
    render json: {message: "Subscriber not created: #{error.message}"}, formats: :json, status: :forbidden
  end

  ##
  # PATCH /api/subscribers/:id
  def update
    subscriber = Subscriber.find(params[:id])
    subscriber.status = params[:status]
    subscriber.save!
    render json: {message: "Subscriber updated successfully"}, formats: :json, status: :ok
  end
end
