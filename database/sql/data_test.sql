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

-- insert into ___.bloc (name, model, shape, geom) values ('test_bloc', 'test_model', 'polygon', st_geomfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2154));
-- insert into ___.test_bloc (shape, name, DBO5, Q, EH) values ('polygon', 'test_bloc', 1, 2, 3);

-- insert into ___.bloc(name, model, shape, geom, ss_blocs) 
-- values ('test_bloc2', 'test_model', 'polygon', st_geomfromtext('POLYGON((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), array[1]);
-- update ___.bloc set sur_bloc = (select id from ___.bloc where name = 'test_bloc2') where name = 'test_bloc';

-- insert into ___.link (up, down, up_to_down) values (2, 1, array['Q', 'DBO5']::varchar[]);

-- insert into api.test_bloc0 (id, shape, name, geom, model, DBO5, Q, EH) values (3, 'polygon', 'test_bloc3', st_geomfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model', 4, 5, 6);
-- insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model');
-- insert into api.test_bloc(geom, model) values ('test_bloc5', st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'test_model');

insert into api.test_bloc(geom, model, name) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model', 'bloc1');
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((0.1 0.1, 0.1 0.9, 0.1 0.1, 0.9 0.1, 0.1 0.1))', 2154), 'test_model');
select name, sur_bloc, ss_blocs from api.test_bloc;
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'test_model');
select schemaname as schema,  sequencename as sequence, last_value from pg_sequences ;

insert into api.piptest_bloc(geom, model) values (st_geomfromtext('lineString(-1 -1, 1 1)', 2154), 'test_model');

-- select * from ___.model;
-- select id, sur_bloc, ss_blocs from api.test_bloc;
-- select * from ___.test_bloc;
-- select * from ___.bloc;

-- delete from api.test_bloc where name = 'test_bloc4';

-- select * from ___.bloc ; 
-- select column_name from information_schema.columns where table_name = 'test_bloc' and table_schema = '___';

