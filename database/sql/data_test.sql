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
insert into api.test_bloc(geom, model, name) values (st_geomfromtext('polygon((0 0, 0 1, 1 1, 1 0, 0 0))', 2154), 'test_model', 'bloc1');
 
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((0.1 0.1, 0.1 0.9, 0.9 0.1, 0.1 0.1))', 2154), 'test_model');
select name, sur_bloc, ss_blocs from api.test_bloc;

insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((-1 -1, -1 2, 2 2, 2 -1, -1 -1))', 2154), 'test_model');

-- -- select schemaname as schema,  sequencename as sequence, last_value from pg_sequences ;
insert into api.test_bloc (geom, model) values (st_geomfromtext('polygon((2 2, 2 3, 3 3, 3 2, 2 2))', 2154), 'test_model');
select name, id from api.bloc ; 
insert into api.piptest_bloc(geom, model) values (st_geomfromtext('lineString(0.5 0.5, 2.5 2.5)', 2154), 'test_model');

select * from api.link ; 
insert into api.test_bloc(geom, model) values (st_geomfromtext('polygon((1 1, 1 2.8, 2.8 2.8, 2.8 1, 1 1))', 2154), 'test_model');
select * from api.link ; 

select api.add_new_formula('Q = 2*EH', 'Q = 2*EH', '2', 'hmm') ;

select api.get_blocs('test_model') ;  

select api.get_links('test_model') ;    

select api.add_new_formula('Delamgie', 'CO2=E', 2, 'C''est vraiment de la magie') ;

update api.input_output set default_formulas = array_append(default_formulas, 'Delamgie') where b_type = 'test' ;

select api.insert_inp_out('test', 'lol', 'real', 'null', 'added', 'input') ;
select api.insert_inp_out('test', 'lol', 'integer', 'null', 'modif', 'input') ;
select api.insert_inp_out('test', 'lol', '', 'null', 'remove', 'input') ;
drop view api.test_bloc ;
select template.bloc_view('test', 'bloc', 'Polygon') ; 
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

create or replace function api.pop(fifo table, lifo_or_fifo boolean default false) 
language plpgsql
returns varchar as
$$
declare 
    idx_m integer ; 
    val varchar ;
begin
    if not lifo_or_fifo then
        select min(id) into idx_m from fifo ; 
    else 
        select max(id) into idx_m from fifo ;
    select min(id) into idx_m from fifo ; 
    select value into val from fifo where id = idx_m ; 
    delete from fifo where id = idx_m ; 
    return val ; 
end ;
$$ ; 


create or replace function api.calculate_bloc(id_bloc integer, model text)
language plpgsql
return jsonb as
$$
declare  
    b_typ ___.bloc_type ;
    to_calc varchar ;
    data_ varchar ; 
    bil varchar ;
    args varchar[] ; 
    f varchar ;
    detail integer ;
    c integer ; 
    result real ;
    json_result jsonb ;
    colnames varchar[] ;
begin 
    select api.recup_entree(id, model) ;
    select into b_typ b_type from api.bloc where id = id and model = model ;
    
    create temp table inp_out(name varchar, val real) ; 
    select column_name into colnames from information_schema.columns, api.input_output  
    where table_name = b_typ||'_bloc' and table_schema = 'api' and 
    b_type = b_typ and (column_name = any(inputs) or column_name = any(outputs)) ;
    query := 'insert into inp_out(name, val) select quote_elem(unnest(colnames)), unnest(colnames) from api.'||b_typ||'_bloc where id = id_bloc' ; 
    execute query ;
    -- à tester  

    create temp table bilan(leftside varchar, calc_with varchar[], formula varchar, detail_level integer) on commit drop;
    
    with bloc_formula as (select formula, detail_level from api.formulas where name = any((select default_formulas from api.input_output where b_type = b_typ)))
    insert into bilan(leftside, calc_with, formula, detail_level) 
    select split_part(formula, '=', 1), api.read_formula(split_part(formula, '=', 2)), formula, detail_level from bloc_formula ;

    create temp table known_data(leftside varchar, known boolean default false) on commit drop;
    insert into known_data(leftside) select unnest(inp_out) ;

    create temp table results(name varchar, detail_level integer, val real) on commit drop ; 

    for data_, args in (select lefside, calc_with from bilan) loop
        create temp fifo(id serial primary key, value varchar) ; 
        create temp treatment_lifo(id serial primary key, value varchar) ; 

        insert into fifo(value) values (data_) ;
        c := 0 ; 
        while c < 10000 and (select count(*) from fifo) > 0 loop
            c := c + 1 ;
            to_calc := api.pop(fifo) ;
            if to_calc in (select leftside from known_data where known = false) and to_calc in (select leftside from bilan) then 
                insert into treatment_lifo(value) values (to_calc) ;
                update known_data set known = true where leftside = to_calc ;
                insert into fifo(value) select unnest(calc_with) where unnest(calc_with) not in (select leftside from known_data where known = true) ;
            end if ;
        end loop ;
        if c = 10000 then 
            raise exception 'Too many iterations' ;
        end if ;
        c := 0 ; 
        while c < 10000 and (select count(*) from treatment_lifo) > 0 loop
            c := c + 1 ;
            to_calc := api.pop(treatment_lifo, true) ;
            for f, detail in (select formula, detail_level from bilan where leftside = to_calc) loop
                result := api.calculate_formula(f, inp_out) ;
                insert into results(name, detail_level, val) values (to_calc, detail, result) ;
            end loop ;

-- ------------------------------------------------------------------------------------------------
-- -- tests select for calculation
-- ------------------------------------------------------------------------------------------------

-- -- Step 1 : sur_blocs, ss_blocs 



-- select id from api.bloc where sur_bloc is null ; 
-- -- Or select id from api.bloc where sur_bloc = 3 ; for example 


-- select id, sur_bloc, name, formula, inputs, outputs from api.bloc b, api.input_output i_o where model = 'test_model' 
-- and api.bloc.b_type = api.input_output.b_type ;

-- -- We do this until there are no results left and we stock the results in the class bloc, so recursively or while loop 

-- -- For it to simplier, we will select all the ids and sur_bloc and use python to do the rest
-- select id, sur_bloc from api.bloc where model = 'test_model' ;

-- select id, sur_bloc from api.bloc where model = 'test_model' and st_within(geom, (select geom from api.bloc where name = 'test_bloc_1'));


-- -- Step 2 : links and concrete blocs

-- select up, down from api.link where model = 'test_model' ;
-- -- En suite on veut les outputs pour up et les inputs pour down :
-- -- select b_type from api.bloc where id = up ;  
-- -- select inputs from api.input_output where b_type =  type ; 


-- insert into api.piptest_bloc(geom, model) values (st_geomfromtext('LINESTRING(-101068 954869,121002 852717,286815 780174)', 2154), 'test_model');
-- insert into api.test_bloc(geom, model) values (st_geomfromtext('POLYGON((67705 981518,301620 987440,29213 678021,67705 981518))', 2154), 'test_model');
-- insert into api.test_bloc(geom, model) values (st_geomfromtext('POLYGON((439303 963752,454108 682463,659894 821627,439303 963752))', 2154), 'test_model');
-- with dumps as (select id, st_dump(st_points(geom_ref)) as dp
--         from ___.bloc where shape = 'LineString'
--         ),
--         startpoints as (select id, (dp).geom as geo from dumps where (dp).path[1] = 1
--         )
-- select api.bloc.id, st_astext(geo) from startpoints, api.bloc where st_intersects(geo, geom_ref) ; 


-- select api.get_up_to_down('test_model') ;
-- -- Step 3 : Calculation mais là c'est plus que du python.

-- insert into ___.bloc(name, model, shape, geom_ref) values ('test_bloc', 'a', 'Polygon', st_geomfromtext('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2154));

-- insert into ___.model(name) values ('a');

-- create or replace function api.test_bloc_instead_fct()
-- returns trigger
-- language plpgsql volatile security definer as
-- $fct$
-- declare
--     overloaded_geom geometry; -- used in start_section to modify geom type
-- begin

--     if tg_op = 'INSERT' or tg_op = 'UPDATE' then
--         new.b_type := 'test'::___.bloc_type ;        new.geom_ref := api.make_polygon(new.geom, 'Polygon');        new.ss_blocs := api.find_ss_blocs(new.id, new.geom_ref, new.model);
--         new.sur_bloc := api.find_sur_bloc(new.id, new.geom_ref, new.model);
--     end if;
--     if tg_op = 'DELETE' then
--         update ___.bloc set ss_blocs = array_remove(ss_blocs, old.id) where id = old.sur_bloc; -- remove the bloc from the list of sub-blocs of the sur-bloc
--         update ___.bloc set sur_bloc = api.find_sur_bloc(old.id, old.geom, old.model) where sur_bloc = old.id; -- update the sur-bloc
--     end if;
--     if tg_op = 'INSERT' then
--         raise notice '%, %, %, %, %, %, %, %' , new.id, new.shape, new.name, new.geom, new.dbo5, new.q, new.eh, new.formula;
--         insert into ___.bloc(id, name, model, shape, geom_ref, ss_blocs, sur_bloc, b_type) values (new.id, new.name, new.model, new.shape, new.geom_ref, new.ss_blocs, new.sur_bloc, new.b_type) ;
--         raise notice 'bonjour bloc' ;
--         insert into ___.test_bloc(id, shape, name, geom, dbo5, q, eh, formula) values (new.id, new.shape, new.name, new.geom, new.dbo5, new.q, new.eh, new.formula) ;
--         raise notice 'bonjour test_bloc' ; 
--       perform api.update_links(new.id, 'Polygon', new.geom, new.model);        return new;
--     elsif tg_op = 'UPDATE' then
--         update ___.bloc set id=new.id, name=new.name, model=new.model, shape=new.shape, geom_ref=new.geom_ref, ss_blocs=new.ss_blocs, sur_bloc=new.sur_bloc, b_type=new.b_type where id=old.id;
--         if ___.current_config() is null then
--             update ___.test_bloc set id=new.id, shape=new.shape, name=new.name, geom=new.geom, dbo5=new.dbo5, q=new.q, eh=new.eh, formula=new.formula where id=old.id;
--         else
--             insert into ___.test_bloc_config(id, shape, name, geom, dbo5, q, eh, formula, config) values (new.id, new.shape, new.name, new.geom, new.dbo5, new.q, new.eh, new.formula, api.current_config())             on conflict on constraint test_bloc_config_pkey do
--             update set id=new.id, shape=new.shape, name=new.name, geom=new.geom, dbo5=new.dbo5, q=new.q, eh=new.eh, formula=new.formula;
--         end if;

--     if not St_equals(old.geom, new.geom) then
--         update ___.link set geom = st_setpoint(geom, 0, new.geom) where up = new.id;
--         update ___.link set geom = st_setpoint(geom, -1, new.geom) where down = new.id;
--     end if;
--         return new;
--     elsif tg_op = 'DELETE' then
--         delete from ___.bloc where id=old.id;
--         delete from ___.test_bloc where id=old.id;
--         return old;
--     end if;
-- end;
-- $fct$ ;



-- INSERT INTO "api"."test_bloc"(
--     "geom", "name", "id", "shape", "dbo5", "q", "eh", "formula", "ss_blocs", "b_type", "geom_ref", "sur_bloc", "model"
-- ) VALUES (
--     ST_GeomFromWKB('\x01030000000100000005000000aea116058add02c11401c3dc8b53294150318e5c115c03c1440a4e6a8b8e244150e428341532f440ebe7c8b6907b244114296a1bcf5ef6400433a4a7abe12841aea116058add02c11401c3dc8b532941'::bytea, 2154),
--     'test_bloc_2',
--     2,
--     'Polygon',
--     NULL,
--     NULL,
--     NULL,
--     E'{"Q = 2*EH"}',
--     E'{}',
--     '',
--     NULL,
--     NULL,
--     'a'
-- ) RETURNING "name";

-- INSERT INTO "api"."test_bloc"("geom","name","id","shape","dbo5","q","eh","formula","ss_blocs","b_type","geom_ref","sur_bloc","model") VALUES 
-- (st_geomfromwkb('\x0103000000010000000500000078bd940b739304416caedee02b442b41447f92ae67b40a41cac0f4fb2aba214134a0b76cf0ce20415db46569b65b2341fe20122a49931c41df1e9e0969cc2c4178bd940b739304416caedee02b442b41'::bytea,2154),
-- 'test_bloc_3',1,'Polygon',NULL,NULL,NULL,E'{"Q = 2*EH"}',E'{}','',NULL,NULL,'a') RETURNING "name" ;