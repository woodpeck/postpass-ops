# Indexes

## Standard osm2pgsql indexes
    
    CREATE INDEX planet_osm_line_osm_id_idx         
        ON public.planet_osm_line 
        USING btree (osm_id);
    
    CREATE INDEX planet_osm_line_way_idx         
        ON public.planet_osm_line 
        USING gist (way);
    
    CREATE INDEX planet_osm_point_osm_id_idx         
        ON public.planet_osm_point 
        USING btree (osm_id);
    
    CREATE INDEX planet_osm_roads_osm_id_idx         
        ON public.planet_osm_roads 
        USING btree (osm_id);
    
    CREATE INDEX planet_osm_roads_way_idx         
        ON public.planet_osm_roads 
        USING gist (way);
    
    CREATE INDEX planet_osm_ways_nodes_bucket_idx         
        ON public.planet_osm_ways 
        USING gin (public.planet_osm_index_bucket(nodes));
    
    CREATE INDEX planet_osm_polygon_way_idx         
        ON public.planet_osm_polygon 
        USING gist (way);
    
    CREATE INDEX planet_osm_polygon_osm_id_idx         
        ON public.planet_osm_polygon 
        USING btree (osm_id);
    
    CREATE INDEX planet_osm_rels_node_members_idx         
        ON public.planet_osm_rels 
        USING gin (public.planet_osm_member_ids(members, 'N'::character(1))) WITH (fastupdate=off);
    
    CREATE INDEX planet_osm_rels_way_members_idx         
        ON public.planet_osm_rels 
        USING gin (public.planet_osm_member_ids(members, 'W'::character(1))) WITH (fastupdate=off);

## Standard osm-carto indexes
    
    CREATE INDEX planet_osm_line_ferry         
        ON public.planet_osm_line 
        USING gist (way) 
        WHERE ((route = 'ferry'::text) AND (osm_id > 0));
    
    CREATE INDEX planet_osm_line_label         
        ON public.planet_osm_line 
        USING gist (way) 
        WHERE ((name IS NOT NULL) OR (ref IS NOT NULL));
    
    CREATE INDEX planet_osm_line_river         
        ON public.planet_osm_line 
        USING gist (way) 
        WHERE (waterway = 'river'::text);
    
    CREATE INDEX planet_osm_line_waterway         
        ON public.planet_osm_line 
        USING gist (way) 
        WHERE (waterway = ANY (ARRAY['river'::text, 'canal'::text, 'stream'::text, 'drain'::text, 'ditch'::text]));
    
    CREATE INDEX planet_osm_point_way_idx         
        ON public.planet_osm_point 
        USING gist (way);
    
    CREATE INDEX planet_osm_point_place         
        ON public.planet_osm_point 
        USING gist (way) 
        WHERE ((place IS NOT NULL) AND (name IS NOT NULL));
    
    CREATE INDEX planet_osm_polygon__admin_gist         
        ON public.planet_osm_polygon 
        USING gist (way) 
        WHERE (boundary = 'administrative'::text);
    
    CREATE INDEX planet_osm_polygon_admin         
        ON public.planet_osm_polygon 
        USING gist (public.st_pointonsurface(way)) 
        WHERE ((name IS NOT NULL) 
        AND (boundary = 'administrative'::text) AND (admin_level = ANY (ARRAY['0'::text, '1'::text, '2'::text, '3'::text, '4'::text])));
    
    CREATE INDEX planet_osm_polygon_military         
        ON public.planet_osm_polygon 
        USING gist (way) 
        WHERE (((landuse = 'military'::text) 
        OR (military = 'danger_area'::text)) AND (building IS NULL));
    
    CREATE INDEX planet_osm_polygon_name         
        ON public.planet_osm_polygon 
        USING gist (public.st_pointonsurface(way)) 
        WHERE (name IS NOT NULL);
    
    CREATE INDEX planet_osm_polygon_name_z6         
        ON public.planet_osm_polygon 
        USING gist (public.st_pointonsurface(way)) 
        WHERE ((name IS NOT NULL) 
        AND (way_area > (5980000)::double precision));
    
    CREATE INDEX planet_osm_polygon_nobuilding         
        ON public.planet_osm_polygon 
        USING gist (way) 
        WHERE (building IS NULL);
    
    CREATE INDEX planet_osm_polygon_water         
        ON public.planet_osm_polygon 
        USING gist (way) 
        WHERE ((waterway = ANY (ARRAY['dock'::text, 'riverbank'::text, 'canal'::text])) 
        OR (landuse = ANY (ARRAY['reservoir'::text, 'basin'::text])) OR ("natural" = ANY (ARRAY['water'::text, 'glacier'::text])));
    
    CREATE INDEX planet_osm_polygon_way_area_z10         
        ON public.planet_osm_polygon 
        USING gist (way) 
        WHERE (way_area > (23300)::double precision);
    
    CREATE INDEX planet_osm_polygon_way_area_z6         
        ON public.planet_osm_polygon 
        USING gist (way) 
        WHERE (way_area > (5980000)::double precision);
    
    CREATE INDEX planet_osm_roads_admin         
        ON public.planet_osm_roads 
        USING gist (way) 
        WHERE (boundary = 'administrative'::text);
    
    CREATE INDEX planet_osm_roads_admin_low         
        ON public.planet_osm_roads 
        USING gist (way) 
        WHERE ((boundary = 'administrative'::text) 
        AND (admin_level = ANY (ARRAY['0'::text, '1'::text, '2'::text, '3'::text, '4'::text])));
    
    CREATE INDEX planet_osm_roads_roads_ref         
        ON public.planet_osm_roads 
        USING gist (way) 
        WHERE ((highway IS NOT NULL) AND (ref IS NOT NULL));

## Additional indexes created for the postpass instance

    CREATE INDEX planet_osm_line_name         
        ON public.planet_osm_line 
        USING btree (name);
    
    CREATE INDEX planet_osm_point_name         
        ON public.planet_osm_point 
        USING btree (name);
    
    CREATE INDEX planet_osm_polygon__admin_name         
        ON public.planet_osm_polygon 
        USING btree (name) 
        WHERE (boundary = 'administrative'::text);
