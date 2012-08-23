#map-gather

Version 0.0.1

A command-line ruby script to scrape an ArcGIS Map Server REST API end-point and store the features in a CSV file.

###Dependencies

- Ruby
- [rest-client](https://github.com/archiloque/rest-client)

###Usage

`$ ruby map-gather.rb REST_API_URL OUTPUT_FILE_NAME`

Example:

`$ ruby map-gather.rb http://www.example.com/ArcGIS/rest/services/folder_name/map_name/MapServer/layer_index/query output.csv`

###TODO

- Better error handling/checking
- Add optional arguments to modify query parameters
- Add optional arguments to adjust throttle time
- Create tests