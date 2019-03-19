require 'faraday'
require 'sinatra'

#time_zone = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

get '/tree-permits' do
	url = URI('https://opendata.arcgis.com/datasets/f92460468c17413d8b2fb42a2c1df4d2_0.geojson')
	thisWeek = Date.today-7
	url.query = Faraday::Utils.build_query(
		'$order' => 'PlanNumber DESC',
    		'$limit' => 1000,
		'$where' => "PlanNumber IS NOT NULL" +
		" AND ReviewStatus = 'Approved' OR ReviewStatus = 'Intended decision'"+
		" AND PropertyAddress IS NOT NULL")

connection = Faraday.new(url: url.to_s)
response = connection.get

collection = JSON.parse(response.body)
  

features = collection['features'].map do |record|

	id = "#{record['properties']['ID']}"

	title ="A new tree permit (#{record['properties']['PlanNumber']}) with the status: '#{record['properties']['ReviewStatus']}' has been issued at #{record['properties']['PropertyAddress']}."

	record.merge('id' => id, 'title' => title)
end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
