class HomesController < ApplicationController
  # skip_before_action :authenticate_request
  # skip_before_action :verify_authenticity_token

  def index
    render json: "success", status: :ok
  end
end
