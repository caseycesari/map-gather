require 'rubygems'
require 'json'
require 'csv'
require 'enumerator'
require 'rest_client'

# Check to make sure we have all the required arguments
def startUpCheck()
  if ARGV.empty? || ARGV[0].nil? ||  ARGV[1].nil?
    abort("You must specify a URL and output file name: " + 
      "ruby map-gather.rb http://www.example.com/ArcGIS/rest/services/org/map/MapServer/0/query output.csv"
    )
  end

  $url = ARGV[0]
  $outfile = ARGV[1]
end

# Get a list of all the ObjectIDS for the specified layer (i.e. $url)
def getOIDS
  params = {
    :where => 'OBJECTID IS NOT NULL',
    :returnIdsOnly => true,
    :f => 'pjson'
  }

  RestClient.get($url, { :params => params }){ |response, request, result, &block|
    case response.code
    when 200
      parseOIDS(response)
    else
      puts "Error"
      response.return!(request, result, &block)
    end
  }
end

# Turn the JSON OID query response into an array of OIDS
def parseOIDS(response) 
  oids = []

  JSON.parse(response.body)["objectIds"].each do |oid|
    oids.push(oid)
  end

  return oids
end

# Get each feature by its corresponding OID by doing a WHERE OBJECTID IN (1, 2, 3...)
# Done in blocks of 100. Greater than 100 OID breaks the URL
def getFeatures(oids)
  count = 0
  params = {
    :outFields => '*',
    :returnGeometry => false,
    :f => 'pjson'
  }

  oids.each_slice(100) do |ids|
    where = "OBJECTID IN (#{ids[0...101].join(',')})"
    params["where"] = where

    RestClient.get($url, {:params => params }){ |response, request, result, &block|
      case response.code
      when 200
        parseFeatures(response)
        count = count + ids.length
        updatePercentage(count, ids.last())
      else
        puts "error"
        response.return!(request, result, &block)
      end
    }
  end

  $csv.close()
end

# Parse and write the returned features to the output CSV file
def parseFeatures(response) 
  JSON.parse(response.body)["features"].each do |feature|
    if $header == false
      $csv << feature["attributes"].keys
      $header = true
    end

    $csv << feature["attributes"].values
  end
end

# Show the user how far along the feature gathering/writing process is
def updatePercentage(count, id)
  percent = (count.to_f() / $oids.length.to_f()) * 100
  
  if percent == 100
    puts "Done!"
  else
    puts "...at OID #{id}, #{percent}% Done"
    sleep 2 # throttle requests
  end
end

# Run
startUpCheck()

puts "Getting list of OBJECTIDs..."
$oids = getOIDS()
puts "Success!" 

puts "Creating output file..."
$header = false
$csv = CSV.open($outfile, "w")

puts "Getting and saving features..."
getFeatures($oids)
