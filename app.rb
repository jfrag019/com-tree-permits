require 'faraday'
require 'sinatra'

#time_zone = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

get '/tree-permits' do
	url = URI('https://services1.arcgis.com/CvuPhqcTQpZPT9qY/arcgis/rest/services/Tree_Permits/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json')
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
  
  features = collection.map do |record|
title =
      "A new tree permit (#{record['PlanNumber']}) with the status: '#{record['ReviewStatus']}' has been issued at #{record['PropertyAddress']}."

  {
    'id' => record['PlanNumber'],
    'type' => 'Feature',
    'properties' => record.merge('title' => title),
    'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          record['x'].to_f,
          record['y'].to_f
        ]
      }
  }
  end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
