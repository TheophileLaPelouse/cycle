create extension if not exists postgis;

-- \i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/data_test.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/data.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/api.sql


------------------------------------------------------------------------------------------------
-- function tests
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-- insert and select tests
------------------------------------------------------------------------------------------------

select ___.current_config();

-- select ___.unique_name('test_bloc', abbreviation=>'test_bloc');

insert into ___.model (comment) values ('model for testing');

insert into ___.model(name) values ('test_model');

-- insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model');

-- select geom::geometry(LineString,2154) from ___.bloc ;

-- insert into ___.bloc (name, model, shape, geom) values ('test_bloc', 'test_model', 'polygon', st_geomfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2154));
-- insert into ___.test_bloc (shape, name, DBO5, Q, EH) values ('polygon', 'test_bloc', 1, 2, 3);

-- insert into ___.bloc(name, model, shape, geom, ss_blocs) 
-- values ('test_bloc2', 'test_model', 'polygon', st_geomfromtext('POLYGON((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), array[1]);
-- update ___.bloc set sur_bloc = (select id from ___.bloc where name = 'test_bloc2') where name = 'test_bloc';

-- insert into ___.link (up, down, up_to_down) values (2, 1, array['Q', 'DBO5']::varchar[]);

-- insert into api.test_bloc0 (id, shape, name, geom, model, DBO5, Q, EH) values (3, 'polygon', 'test_bloc3', st_geomfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model', 4, 5, 6);
-- insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model');
-- insert into api.test_bloc(geom, model) values ('test_bloc5', st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'test_model');


-- ici
-- select st_astext(api.make_polygon(st_geomfromtext('lineString(-1 -1, 1 1)', 2154), 'LineString'::___.geo_type)) ; 
-- select st_astext(api.make_polygon(st_geomfromtext('point(0 0)', 2154), 'Point'::___.geo_type)) ;
-- select st_astext(api.make_polygon(st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'Polygon'::___.geo_type)) ;
-- select st_within(api.make_polygon(st_geomfromtext('point(0 0)', 2154), 'Point'::___.geo_type), api.make_polygon(st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'Polygon'::___.geo_type)) ;
insert into api.test_bloc(geom, model, name) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model', 'bloc1');
 
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((0.1 0.1, 0.1 0.9, 0.9 0.1, 0.1 0.1))', 2154), 'test_model');
-- select name, sur_bloc, ss_blocs from api.test_bloc;

insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'test_model');

-- -- select schemaname as schema,  sequencename as sequence, last_value from pg_sequences ;
insert into api.test_bloc (geom, model) values (st_geomfromtext('polygon((2 2, 2 3, 3 3, 3 2, 2 2))', 2154), 'test_model');
select name, id from api.bloc ; 
insert into api.piptest_bloc(geom, model) values (st_geomfromtext('lineString(0.5 0.5, 2.5 2.5)', 2154), 'test_model');

select * from api.link ; 
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((1 1, 1 2.8, 2.8 2.8, 2.8 1, 1 1))', 2154), 'test_model');
select * from api.link ; 
-- insert into api.piptest_bloc(geom, model) values (st_geomfromtext('lineString(1 1, 2 2)', 2154), 'test_model');

-- select * from api.bloc ; 
-- select * from api.link ; 
-- select api.update_links(4, 'LineString'::___.geo_type, st_geomfromtext('LineString(-1 -1, 1 1)', 2154), 'test_model');
-- select * from ___.model;
-- select id, sur_bloc, ss_blocs from api.test_bloc;
-- select * from ___.test_bloc;
-- select * from ___.bloc;

-- delete from api.test_bloc where name = 'test_bloc4';

-- select * from ___.bloc ; 
-- select column_name from information_schema.columns where table_name = 'test_bloc' and table_schema = '___';

-- select attribute_name, data_type from information_schema.attributes where udt_schema = '___' and udt_name = 'bloc_type'; 


-- ------------------------------------------------------------------------------------------------
-- -- tests select for calculation
-- ------------------------------------------------------------------------------------------------

-- -- Step 1 : sur_blocs, ss_blocs 

-- select id from api.bloc where sur_bloc is null ; 
-- -- Or select id from api.bloc where sur_bloc = 3 ; for example 


select id, sur_bloc, name, formula, inputs, outputs from api.bloc, api.input_output where model = 'test_model' 
and api.bloc.b_type = api.input_output.b_type ;

-- -- We do this until there are no results left and we stock the results in the class bloc, so recursively or while loop 

-- -- For it to simplier, we will select all the ids and sur_bloc and use python to do the rest
-- select id, sur_bloc from api.bloc where model = 'test_model' ;

-- select id, sur_bloc from api.bloc where model = 'test_model' and st_within(geom, (select geom from api.bloc where name = 'test_bloc_1'));


-- -- Step 2 : links and concrete blocs

-- select up, down from api.link where model = 'test_model' ;
-- -- En suite on veut les outputs pour up et les inputs pour down :
-- -- select b_type from api.bloc where id = up ;  
-- -- select inputs from api.input_output where b_type =  type ; 


LINESTRING(-101068.30116898331 954869.959378198,121002.49898858764 852717.3913057153,286815.36310624063 780174.2632542421)
POLYGON((67705.50695077062 981518.4553971065,301620.08311674534 987440.3434013084,29213.23492345831 678021.6951817595,67705.50695077062 981518.4553971065))
POLYGON((439303.9792144393 963752.7913845008,454108.699224944 682463.1111849109,659894.3073709598 821627.4792836554,439303.9792144393 963752.7913845008))
-- select api.get_up_to_down('test_model') ;
-- -- Step 3 : Calculation mais là c'est plus que du python.
