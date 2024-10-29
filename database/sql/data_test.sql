create extension if not exists postgis;

-- \i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/data_test.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/data.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/api.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/formula.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/specials_blocs.sql

\i C:/Users/theophile.mounier/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/cycle/database/sql/blocs.sql

------------------------------------------------------------------------------------------------
-- function tests
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-- insert and select tests
------------------------------------------------------------------------------------------------

select api.add_new_bloc('pointest', 'bloc', 'Point',
    additional_columns => '{t.FE as FE, t.description as description}',
    additional_join => 'left join ___.zone_type_table as t on t.name=c.zon') ;

select ___.current_config();

-- select ___.unique_name('test_bloc', abbreviation=>'test_bloc');

-- insert into ___.model (comment) values ('model for testing');

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
select api.add_new_formula('Delamgie', 'co2_e=10*eh/((2^10*(1<0)+1))', 2, 'C''est vraiment de la magie') ;
select api.add_new_formula('magiemagie', 'co2_e=1*eh', 2, 'C''est vraiment de la magie') ;
select api.add_new_formula('abracadabra', 'n2o_e=1*eh', 2, 'C''est vraiment de la magie') ;
update api.input_output set default_formulas = array_append(default_formulas, 'Delamgie') where b_type = 'test' ;
update api.input_output set default_formulas = array_append(default_formulas, 'magiemagie') where b_type = 'test' ;
update api.input_output set default_formulas = array_append(default_formulas, 'abracadabra') where b_type = 'test' ;
-- update api.test_bloc set q = 10, eh = 5 where id = 1  ;

-- select api.get_results_ss_bloc(1) ; 
insert into api.test_bloc(geom, model, eh) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model', 4);
insert into api.test_bloc(geom, model, eh) values (st_geomfromtext('polygon((0.1 0.1, 0.1 0.9, 0.9 0.1, 0.1 0.1))', 2154), 'test_model', 1);
insert into api.test_bloc(geom, model, eh) values (st_geomfromtext('polygon((0.2 0.2, 0.2 0.95, 0.95 0.2, 0.2 0.2))', 2154), 'test_model', 2);
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'test_model');
select id, sur_bloc, ss_blocs from api.test_bloc;

-- select id, name, val, result_ss_blocs, formula, co2_eq from ___.results order by id ;

select api.get_histo_data('test_model');
-- select name, sur_bloc, ss_blocs from api.test_bloc;
-- delete from api.test_bloc where name = 'bloc1'

-- update api.test_bloc set q = 10, eh = 11 where id = 2  ;

-- -- select schemaname as schema,  sequencename as sequence, last_value from pg_sequences ;
-- insert into api.test_bloc (geom, model, eh) values (st_geomfromtext('polygon((2 2, 2 3, 3 3, 3 2, 2 2))', 2154), 'test_model', 12);
-- select name, id from api.bloc ; 
-- insert into api.piptest_bloc(geom, model, q) values (st_geomfromtext('lineString(0.5 0.5, 2.5 2.5)', 2154), 'test_model', 10);

-- select * from api.link ; 
-- insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((1 1, 1 2.8, 2.8 2.8, 2.8 1, 1 1))', 2154), 'test_model');
-- select * from api.link ; 

-- select api.add_new_formula('q = 2*eh', 'co2_c = 2*eh+q', '2', 'hmm') ;

-- select api.get_blocs('test_model') ;  

-- select api.get_links('test_model') ;    

-- select api.insert_inp_out('test', 'lol', 'real', 'null', 'added', 'input') ;
-- select api.insert_inp_out('test', 'lol', 'integer', 'null', 'modif', 'input') ;
-- select api.insert_inp_out('test', 'lol', '', 'null', 'remove', 'input') ;
-- drop view api.test_bloc ;
-- select template.bloc_view('test', 'bloc', 'Polygon') ; 
-- select api.add_formula_to_input_output('test', 'Delamgie') ; 
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

-- select jsonb_build_object(b_types, jsonb_object_agg(f.formula, f.detail_level)) from api.input_output i_o join api.formulas f on f.name = any(i_o.default_formulas) group by b_types;

-- select api.read_formula('Q= 2* EH', array['Q', 'EH']) ;


-- update api.test_bloc set q = 10, eh = 5 where id = 1  ;
-- select api.calculate_bloc(5, 'test_model') ;


-- ------------------------------------------------------------------------------------------------
-- -- tests select for calculation
-- ------------------------------------------------------------------------------------------------
