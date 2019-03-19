require 'faraday'
require 'sinatra'

#time_zone = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

get '/tree-permits' do
	url = URI('https://services1.arcgis.com/CvuPhqcTQpZPT9qY/arcgis/rest/services/Tree_Permits/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token=')
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
          record['Longitude'].to_f,
          record['Latitude'].to_f
        ]
      }
  }
  end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
