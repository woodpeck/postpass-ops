# Dynamic Leaflet Map

A frequent case of services like Overpass or Postpass is showing features
on a browser map, and loading new data from the server when the map is moved.

## Postpass version

This HTML page loads fast food places from Postpass. It does not allow
zooming out further than z10 because that would load too much data; 
another frequently used method is showing a "please zoom in to see
anything" message when the map is zoomed out too far.

    <!DOCTYPE html>
    <html>
      <head>
        <title>Postpass dynamic map example</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
        <style>
          html, body, #map {
            height: 100%;
            width: 100%;
          }
        </style>
        <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
      </head>
      <body>
        <div id="map" />

        <script>
          var map = L.map('map').setView([49.012, 8.3985], 14);
          var layergroup = L.layerGroup();
          layergroup.addTo(map);
          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            minZoom: 10,
            attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          }).addTo(map);

          // This Postpass query selects points and polygons 
          // that have amenity=fast_food, and converts polygons to 
          // points on the server side.
          // we also set the "pretty" option to false which gives
          // us less whitespace in the result.
          function buildPostpassUrl() {
            let b = map.getBounds();  
            let envelope = `st_makeenvelope( 
                ${b.getWest()}, ${b.getSouth()}, 
                ${b.getEast()}, ${b.getNorth()}, 4326)`;
            let query = `SELECT osm_id, osm_type, tags, st_centroid(geom) 
              FROM postpass_pointpolygon 
              WHERE tags->>'amenity'='fast_food' AND geom && ${envelope}`;
            let url = new URL('https://postpass.geofabrik.de/api/0.2/interpreter?');
            url.searchParams.append("data", query);
            url.searchParams.append("options[pretty]", "false");
            return url;
          }

          map.on("moveend", updateMap);

          async function updateMap() {

            // find out if there is a popup open at the moment
            let aPopupIsOpen = false;
            layergroup.eachLayer(function (layer) {
               layer.eachLayer(function(l) {
                 if (l.isPopupOpen()) { aPopupIsOpen=true; }
               });
            });
            
            // load features from Postpass
            let url = buildPostpassUrl();
            let response = await fetch(url);
            let json = await response.json();

            let geojsonMarkerOptions = {
              radius: 8,
              fillColor: "#ff7800",
              color: "#000",
              weight: 1,
              opacity: 1,
              fillOpacity: 0.8
            };

            let resultLayer = L.geoJson(json, {
              style: function (feature) {
                return {color: "#ff0000"};
              },
              // draw circles instead of the default water drops
              pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, geojsonMarkerOptions);
              },
              // prepare a popup with tags
              onEachFeature: function (feature, layer) {
                let popupContent = "<table><tr><th>@id</th><td>" + 
                  feature.properties.osm_type + "/" + 
                  feature.properties.osm_id + "</td></tr>";
                var keys = Object.keys(feature.properties.tags);
                keys.forEach(function (key) {
                  popupContent = popupContent + "<tr><th>" + key + 
                    "</th><td>" + feature.properties.tags[key] + "</td></tr>";
                });
                popupContent = popupContent + "</table>"
                layer.bindPopup(popupContent);
              }
            });
            // we'd like to always clear old makers after loading new, but
            // this would also kill a popup that is open, so let's not
            if (!aPopupIsOpen) layergroup.clearLayers();
            resultLayer.addTo(layergroup);
          }

          // call updateMap once initially to load markers
          updateMap();
        </script>
      </body>
    </html>
