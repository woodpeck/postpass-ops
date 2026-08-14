#! /bin/bash
set -o errexit -o nounset -o pipefail

export PGUSER=${PGUSER:-osm}
export PGDATABASE=${PGDATABASE:-gis}

for WANTED_CMD in ogr2ogr curl units ; do
	if ! command -v $WANTED_CMD &>/dev/null ; then
		echo "${WANTED_CMD}(1) not installed."
		exit 1
	fi
done

WORKINGDIR=$(realpath "${WORKINGDIR:-$(dirname "$0")}")
export WORKINGDIR

cd "$WORKINGDIR" || exit

export PGAPPNAME="postpass_land_polygons_updater"

if ! psql -XAt -c "select 1" &>/dev/null ; then
	echo 1>&2 "PostgreSQL not running, or you have no access rights"
	psql -XAt -c "select 1"
	exit 1
fi

# If the latest data is <5min, then exit early. Try to save HTTP requests.
if [ "$(psql -XAt -c "select extract(epoch from (now()-value::timestamp))::integer < 300  from land_polygons_properties where property = 'current_timestamp';" &>/dev/null)" = "t" ] ; then
	exit 0
fi

# Download 
timeout 1h curl -s -A "${PGAPPNAME}/1" --remote-time --location -O -z land-polygons-split-4326.zip  https://osmdata.openstreetmap.de/download/land-polygons-split-4326.zip


if [ "$(psql -XAt -c "SELECT count(*) FROM pg_tables WHERE tablename = 'land_polygons_properties';")" -eq 0 ] ; then
	psql -X -c "CREATE TABLE land_polygons_properties (property text not null primary key, value text not null);"
fi

CURRENT_TIMESTAMP=$(psql -XAt -c "select extract(epoch from value::timestamp)::integer from land_polygons_properties where property = 'current_timestamp';")


if [ -z "$CURRENT_TIMESTAMP" ] || [ "$CURRENT_TIMESTAMP" -lt "$(stat -c %Y land-polygons-split-4326.zip)" ] ; then
	echo "Reimporting new land-polgyons-split-4326.zip"
	ls -lh land-polygons-split-4326.zip

	# client_min_messages stops the message if this table doesn't exist.
	psql -qX -c "SET client_min_messages TO 'WARNING'; DROP TABLE IF EXISTS land_polygons_new CASCADE;"

	# No geom index, because when we rename the table, the index doesn't get
	# changed from land_polygons_new_geom (or whatever) and so we can't do an
	# import the next time.
	# the shapefile already has a id column, so just use that. we can't stop
	# ogr2ogr from adding one
	ogr2ogr -select "" -overwrite -nln land_polygons_new -lco GEOMETRY_NAME=geom -lco FID=fid -lco SPATIAL_INDEX=NONE -f PostgreSQL PG: /vsizip/land-polygons-split-4326.zip/land-polygons-split-4326/land_polygons.shp

	psql -qX -c "ALTER TABLE land_polygons_new DROP COLUMN fid;"		# don't need id col.

	# rename table
	psql -qX -c "BEGIN; DROP TABLE IF EXISTS land_polygons CASCADE; ALTER TABLE land_polygons_new RENAME TO land_polygons; CREATE INDEX land_polygons_geom ON land_polygons USING gist (geom) ; COMMIT"
	echo "Renamed land_polygons_new → land_polygons"

	CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d "@$(stat -c %Y land-polygons-split-4326.zip )")
	psql -qX -c "INSERT INTO land_polygons_properties (property, value) VALUES ('current_timestamp', '${CURRENT_TIMESTAMP}') ON CONFLICT (property) DO UPDATE SET value = EXCLUDED.value;"
	echo "Updated land_polygons_properties to set the current_timestamp to \"${CURRENT_TIMESTAMP}\""

else
	echo "No new data to import. Current land_polygons timestamp is $CURRENT_TIMESTAMP / $(date --rfc-3339=seconds -d "@${CURRENT_TIMESTAMP}") / $(( $(date +%s) -  CURRENT_TIMESTAMP )) sec ago / $(units $(( $(date +%s) -  CURRENT_TIMESTAMP ))sec time) ago."
fi
