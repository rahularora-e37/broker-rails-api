module Api
	module V1
		class BrokersController < ApiController
      before_action :set_broker, only: [:update, :destroy, :show]
      
      #return all brokers
      def index
        render_success_response(Broker.all, each_serializer: ::V1::BrokerSerializer)
      end
      
      #Create borker
			def create
        broker = Broker.new(broker_create_params)
        broker.save!
        render_success_response(broker, serializer: ::V1::BrokerSerializer)
      end
      
      #Update broker
      def update
          if @broker.present?
            @broker.update_attributes(broker_create_params)
            render_success_response(@broker, serializer: ::V1::BrokerSerializer)
          else
            render_errors_response(@broker.errors.full_messages, :forbidden)
          end
      end
      
      
      def destroy
        @broker.destroy
        render_success_response([])
      end

			private

			def broker_create_params
        params.require(:broker).permit(
          :name, :street_address, :city,
          :state, :zipcode, :factor_rate
        )
      end

      def set_broker
        @broker = Broker.find(params[:id])
      end
		end
	end
end