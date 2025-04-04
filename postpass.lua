local srid = 4326
local multi_geometry = true

-- ---------------------------------------------------------------------------

-- Ways with any of the following keys will be treated as polygon
local polygon_keys = {
    'aeroway',
    'amenity',
    'building',
    'harbour',
    'historic',
    'landuse',
    'leisure',
    'man_made',
    'military',
    'natural',
    'office',
    'place',
    'power',
    'public_transport',
    'shop',
    'sport',
    'tourism',
    'water',
    'waterway',
    'wetland',
    'abandoned:aeroway',
    'abandoned:amenity',
    'abandoned:building',
    'abandoned:landuse',
    'abandoned:power',
    'area:highway'
}

local polygon_index = {}
for _, k in ipairs(polygon_keys) do
    polygon_index[k] = true
end

local function is_polygon(tags)
    for k, _ in pairs(tags) do
        if polygon_index[k] then
            return true
        end
    end
    return false
end

local tables = {}

tables.point = osm2pgsql.define_table{
    name = 'postpass_point',
    ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
    columns = {
        { column = 'tags',  type = 'jsonb' },
        { column = 'geom',  type = 'point', projection = srid }
    }
}

tables.line = osm2pgsql.define_table{
    name = 'postpass_line',
    ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
    columns = {
        { column = 'tags',  type = 'jsonb' },
        { column = 'geom',  type = 'multilinestring', projection = srid }
    }
}

tables.polygon = osm2pgsql.define_table{
    name = 'postpass_polygon',
    ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
    columns = {
        { column = 'tags',  type = 'jsonb' },
        { column = 'geom',  type = 'multipolygon', projection = srid }
    }
}

local function as_bool(value)
    return value == 'yes' or value == 'true' or value == '1'
end

function osm2pgsql.process_node(object)
    tables.point:insert({
        tags = object.tags,
        geom = object:as_point()
    })
end

function osm2pgsql.process_way(object)

    local polygon
    local area_tag = object.tags.area
    if as_bool(area_tag) then
        polygon = true
    elseif area_tag == 'no' or area_tag == '0' or area_tag == 'false' then
        polygon = false
    else
        polygon = is_polygon(object.tags)
    end

    if add_area then
        polygon = true
    end

    if polygon and object.is_closed then
        tables.polygon:insert({
            tags = object.tags,
            geom = object:as_polygon()
        })
    else
        tables.line:insert({
            tags = object.tags,
            geom = object:as_linestring()
        })
    end
end

function osm2pgsql.process_relation(object)

    local rtype = object:grab_tag('type')
    if (rtype ~= 'route') and (rtype ~= 'multipolygon') and (rtype ~= 'boundary') then
        return
    end

    local make_boundary = false
    local make_polygon = false
    if rtype == 'boundary' then
        make_boundary = true
    elseif rtype == 'multipolygon' and object.tags.boundary then
        make_boundary = true
    elseif rtype == 'multipolygon' then
        make_polygon = true
    end

    if not make_polygon then
        tables.line:insert({
            tags = object.tags,
            geom = object:as_multilinestring()
        })
    end

    if make_boundary or make_polygon then
        local geom = object:as_multipolygon()

        if multi_geometry then
            tables.polygon:insert({
                tags = object.tags,
                geom = geom
            })
        else
            for sgeom in geom:geometries() do
                tables.polygon:insert({
                    tags = object.tags,
                    geom = sgeom
                })
            end
        end
    end
end

