These are the scripts & systemd files uses on postpass.geofabrik.de to import
the OSM Land Polygons (split).

# Installation

This programme needs the commands `ogr2ogr`, `curl` & `units` in `$PATH`. The
systemd files `postpass-land-polygons-update.timer` &
`postpass-land-polygons-update.service` can be used to start updates.

# Usage

Run the `land-polygons-reimport.sh`. It will download the data file to the
current directory (or the contents of the `$WORKINGDIR` envvar), and import to
the `land_polygons` table (creating it if needed).

# Configuration

PostgreSQL connection is configurable via the standard
[`PG*` environmental variables](https://www.postgresql.org/docs/current/libpq-envars.html).

    $ PGUSER=amanda PGDATABASE=amanda ./land-polygons-reimport.sh

Default username is `osm` and default database is `gis`.

# Copright

The data is originally from the OpenStreetMap database. OpenStreetMap data is
available under the
[Open Database Licence](https://opendatacommons.org/licenses/odbl/1.0/), see
also the
[OpenStreetMap Copyright page](https://www.openstreetmap.org/copyright). More
guidance on how to use it can be found on the
[OSM website](https://wiki.osmfoundation.org/wiki/Licence/Community_Guidelines).

The data is processed by the
[OSM Data project](https://osmdata.openstreetmap.de), which is currently
being hosted by [FOSSGIS e.V.](https://www.fossgis.de/).
