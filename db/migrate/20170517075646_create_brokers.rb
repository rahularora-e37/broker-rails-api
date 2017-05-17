class CreateBrokers < ActiveRecord::Migration[5.0]
  def change
    create_table :brokers do |t|
    	t.string  :name
    	t.string  :street_address
    	t.string  :city
    	t.string  :state
    	t.string  :zipcode
    	t.decimal :factor_rate

      t.timestamps
    end
  end
end
