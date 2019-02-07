class ErrorsController < ApplicationController
  before_action :mark_as_error

  def not_found
    render status: 404
  end

  def internal_error
    render status: 500
  end

  private

  def mark_as_error
    @serious_error_occurred = true
  end
end
