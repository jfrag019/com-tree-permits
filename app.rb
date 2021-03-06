require 'sinatra'
require 'rest-client'

get '/tree-permits' do

today = Date.today
twoDaysBefore = Date.today-1

today_s = today.strftime("%F")
twoDaysBefore_s = twoDaysBefore.strftime("%F")

url = 'https://services1.arcgis.com/CvuPhqcTQpZPT9qY/arcgis/rest/services/Tree_Permits/FeatureServer/0/query?where=1%3D1+AND+%28ReviewStatus+LIKE+%27Approved%27+OR+ReviewStatus+LIKE+%27Intended+decision%27%29+AND+PropertyAddress+IS+NOT+NULL+AND+ReviewStatusChangedDate+%3E+%27'+twoDaysBefore_s+'%27+AND+ReviewStatusChangedDate+%3C+%27'+today_s+'%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token='

response = RestClient.get url

collection = JSON.parse(response.body)

features = collection['features'].map do |record|

	id = "#{record['properties']['ID']}"

	title ="New Tree Activity @ #{record['properties']['PropertyAddress']} (#{record['properties']['PlanNumber']}) with a status of #{record['properties']['ReviewStatus']}. For more, visit miamigov.com & search Intended Decision"

{
    'id' => id,
    'type' => 'Feature',
    'properties' => record['properties'].merge('title' => title),
    'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          record['properties']['Longitude'].to_f,
          record['properties']['Latitude'].to_f
        ]
      }
  }
	

end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
