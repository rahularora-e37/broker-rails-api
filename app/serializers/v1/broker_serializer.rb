module V1
  class BrokerSerializer < BaseSerializer
  	attributes :id, :name, :street_address, :city, :state, :zipcode,
  	 :factor_rate, :created_at, :updated_at

  	def created_at
      object.created_at.iso8601
    end

    def updated_at
      object.updated_at.iso8601
    end
  end
end