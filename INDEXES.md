# Indexes

## Standard osm2pgsql indexes
    
    CREATE INDEX planet_osm_rels_node_members_idx
        ON public.planet_osm_rels
        USING gin (public.planet_osm_member_ids(members, 'N'::character(1)));

    CREATE INDEX planet_osm_rels_way_members_idx
        ON public.planet_osm_rels
        USING gin (public.planet_osm_member_ids(members, 'W'::character(1)));

    CREATE INDEX planet_osm_ways_nodes_bucket_idx
        ON public.planet_osm_ways
        USING gin (public.planet_osm_index_bucket(nodes));

    CREATE INDEX postpass_line_geom_idx
        ON public.postpass_line
        USING gist (geom);

    CREATE INDEX postpass_line_osm_type_osm_id_idx
        ON public.postpass_line
        USING btree (osm_type, osm_id);

    CREATE INDEX postpass_point_geom_idx
        ON public.postpass_point
        USING gist (geom);

    CREATE INDEX postpass_point_osm_type_osm_id_idx
        ON public.postpass_point
        USING btree (osm_type, osm_id);

    CREATE INDEX postpass_polygon_geom_idx
        ON public.postpass_polygon
        USING gist (geom);

    CREATE INDEX postpass_polygon_osm_type_osm_id_idx
        ON public.postpass_polygon
        USING btree (osm_type, osm_id);

## Additional indexes created for the postpass instance

    CREATE INDEX postpass_line_name
        ON public.postpass_line
        USING btree (((tags ->> 'name'::text)));

    CREATE INDEX postpass_line_tags 
        ON public.postpass_line 
        USING gin (tags);

    CREATE INDEX postpass_point_name
        ON public.postpass_point
        USING btree (((tags ->> 'name'::text)));
        
    CREATE INDEX postpass_point_tags
        ON public.postpass_point
        USING gin (tags);

    CREATE INDEX postpass_polygon_admin 
        ON public.postpass_polygon
        USING gist (geom)
        WHERE ((tags ->> 'boundary'::text) = 'administrative'::text);

    CREATE INDEX postpass_polygon_name
        ON public.postpass_polygon
        USING btree (((tags ->> 'name'::text)));

    CREATE INDEX postpass_polygon_tags
        ON public.postpass_polygon
        USING gin (tags);
