#map-gather

Version 0.0.1

A command-line ruby script to scrape the tablular data of an ArcGIS Server 
feature layer through the REST API and store the results locally in a CSV.

###Methodology

There is no easy way for a user to get all of the tabular data for a large 
(> 1,000 features) 
[ArcGIS Server](http://www.esri.com/software/arcgis/arcgisserver) feature layer.
ArcGIS Server does not provide "bulk download" functionality, nor does the 
[REST API](http://help.arcgis.com/en/arcgisserver/10.0/apis/rest/) allow you to 
query for more than 1,000 features at a time (at least under the default
server configuration). However, by default, there is no limit on the number 
of results of a query that returns only the `ObjectIDs` for all of the 
features in a layer. 
Therefore, to scrape the tabular data of a feature layer, 
*map-gather* first queries for the `ObjectIDs` of all of the 
features in the provided layer. Then, in batches of 100, 
`WHERE OBJECTD ID IN (1, 2, 3,...)` queries are made (~2 seconds apart, 
as to not overwhelm the server) until all of the features are retrieved. 
The results are written locally to a CSV file.

###Dependencies

- Ruby
- [rest-client](https://github.com/archiloque/rest-client)
- An open (i.e. no auth token/password needed) ArcGIS Server REST API endpoint to query

###Usage

`$ ruby map-gather.rb REST_API_URL OUTPUT_FILE_NAME`

Or, more specifically:

`$ ruby map-gather.rb http://www.example.com/ArcGIS/rest/services/folder_name/map_name/MapServer/layer_index/query output.csv`

Example:

    $ ruby map-gather.rb http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/6/query test.csv
    Getting list of OBJECTIDs...
    Success!
    Creating output file...
    Getting and saving features...
    ...at OID 100, 25.44529262086514% Done
    ...at OID 200, 50.89058524173028% Done
    ...at OID 300, 76.33587786259542% Done
    Done!

Output:

![output sample](http://raw.github.com/caseypt/map-gather/results.png "Output Sample")

###TODO

- Better error handling/checking
- Add optional arguments to modify query parameters
- Add optional arguments to adjust throttle time
- Create tests