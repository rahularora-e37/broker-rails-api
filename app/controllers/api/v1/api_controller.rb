module Api
  module V1
    class ApiController < ::ApplicationController
      include ApiResponder::V1


      respond_to :json
    end
  end
end