require 'faraday'
require 'sinatra'

#time_zone = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

get '/tree-permits' do
	url = URI('https://data.miamigov.com/resource/mwh4-hkbb.json')
	thisWeek = Date.today-7
	url.query = Faraday::Utils.build_query(
		'$order' => 'plannumber DESC',
    		'$limit' => 1000,
		'$where' => "plannumber IS NOT NULL" +
		" AND reviewstatus = 'Approved' OR reviewstatus = 'Intended decision'"+
		" AND propertyaddress IS NOT NULL")

connection = Faraday.new(url: url.to_s)
response = connection.get

collection = JSON.parse(response.body)
  
  features = collection.map do |record|
title =
      "A new tree permit (#{record['plannumber']}) with the status: '#{record['reviewstatus']}' has been issued at #{record['propertyaddress']}."

  {
    'id' => record['plannumber'],
    'type' => 'Feature',
    'properties' => record.merge('title' => title),
    'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          record['longitude'].to_f,
          record['latitude'].to_f
        ]
      }
  }
  end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
