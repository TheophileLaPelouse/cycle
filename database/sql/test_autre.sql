-- do 
-- $$
-- declare 
--     s real ; 
--     i real ;
--     val1 real := 0.1;
--     incert1 real := 0;
--     val2 real := 40;
--     incert2 real := 0.5;
--     -- formula text := co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)
--     reduced_f text := '(0.3618*e + (eh*0.12*(1 + 1)/vit)^0.5)^2 + 24.0*125*60*(0.3618*e + (eh*0.12*(1 + 1)/vit)^0.5)^2*(5.4*1.5*0.75*(h + e) + 80)' ;
--     eh real := 10 ; 
--     qe_eh real := 0.12 ; 
--     vit real := 60 ; 
--     calc text[] ;
-- begin 
--     -- s := (val1 ^ val2)::real;
--     -- raise notice 'jusqu''ici c''est bon' ; 
--     -- i := abs(val2) * incert1 ;
--     raise notice 's %, i %', s, i ;
--     create temp table inp_out (name text, val real, incert real) ;
--     insert into inp_out values('eh', 10, 0.1) ;
--     insert into inp_out values('qe', 20, 0.01) ;
--     insert into inp_out values('vit', 60, 0.5) ;
--     insert into inp_out values('vac', 3, 0.1) ;
--     insert into inp_out values('rho', 4, 0.1) ;
--     insert into inp_out values('tau', 5, 0.1) ;
--     insert into inp_out values('h', 4, 0.1) ;
--     insert into inp_out values('e', 0.25, 0.1) ;
--     insert into inp_out values('fefonda', 8, 0.1) ;
--     insert into inp_out values('fepelle', 9, 0.1) ;
--     insert into inp_out values('cad', 11, 0.1) ;

--     calc := formula.write_formula(reduced_f) ;
--     raise notice 'calc in test_autre %', calc ;
--     raise notice 'result %', formula.calc_incertitudes(calc) ;
--     drop table inp_out ;
-- end ;
-- $$ ;
create or replace function api.bloc_tree()
returns jsonb
language plpgsql as
$$
declare 
    mod varchar ; 
    res jsonb := '{}' ;
begin
    for mod in (select distinct model from api.bloc)
    loop
        -- raise notice 'mod %', mod ;
        -- raise notice 'bloc_tree %', api.build_bloc_tree(mod) ;
        res := jsonb_set(res, array[mod]::text[], api.build_bloc_tree(mod), true) ;
    end loop;
    return res;
end;
$$;

create or replace function api.build_bloc_tree(model_name varchar, id_sur_bloc integer default null)
returns jsonb
language plpgsql as
$$
declare 
    res jsonb := '{}' ;
    blocs integer[] ;
    bloc_json jsonb := '{}' ;
    b integer ; 
    bloc_name varchar ;
begin 
    -- Non récursive terminale, après je pense qu'il n'y a pas de problème de performance sur cette fonction.
    if id_sur_bloc is null then 
        with concr_table as (select b_type, concrete from api.input_output)
        select into blocs array_agg(id) from api.bloc, concr_table where model = model_name and sur_bloc is null
        and api.bloc.b_type = concr_table.b_type and (concrete or api.bloc.b_type='sur_bloc');
    else
        with concr_table as (select b_type, concrete from api.input_output)
        select into blocs array_agg(id) from api.bloc, concr_table where model = model_name and sur_bloc = id_sur_bloc
        and api.bloc.b_type = concr_table.b_type and (concrete or api.bloc.b_type='sur_bloc');
    end if;
    raise notice 'blocs %', blocs ;
    if array_length(blocs, 1) = 0 or blocs is null then 
        return res;
    end if;
    foreach b in array blocs
    loop
        select into bloc_name name from api.bloc where id = b ;
        raise notice 'bloc_json1 %', bloc_json ;
        bloc_json := jsonb_set(bloc_json, array[bloc_name::text], api.build_bloc_tree(model_name, b), true);
        raise notice 'bloc_json2 %', bloc_json ;
    end loop;
    return bloc_json;
end;
$$;
select api.bloc_tree();
-- update api.dessableurdegraisseur set eh = 20 ; 

with concr_table as (select b_type, concrete from api.input_output)
select array_agg(id) from api.bloc, concr_table where model = 'bonjour' and sur_bloc is null
and api.bloc.b_type = concr_table.b_type and (concrete or api.bloc.b_type='sur_bloc');

--  {"bonjour": {"sur_bloc_bloc_1": {"2": {"filiere_eau_1": {"6": {"bassin_dorage_1": {}, "clarificateur_1": {}}}, "filiere_boue_1": {"8": {"compostage_1": {}}}}}}}
-- create view api.results as 
-- with 
-- useable as (select * from ___.results where val is not null and formula is not null), 
-- unsuable as (select * from ___.results where val is null and formula is not null), 
-- norm_lvl_max as (select id, name, max(detail_level) as max_lvl from useable where detail_level < 6 group by id, name), 
-- in_use as (select distinct useable.id, useable.name, useable.detail_level, useable.formula, co2_eq 
-- from useable
-- join norm_lvl_max on useable.id = norm_lvl_max.id and useable.name = norm_lvl_max.name
-- where ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null 
-- and (useable.detail_level = norm_lvl_max.max_lvl or useable.detail_level = 6)
-- ),
-- results as (select id, name, co2_eq from ___.results), 
-- exploit as (select distinct id, name, co2_eq from ___.results where name like '%_e'), 
-- constr as (select distinct id, name, co2_eq from ___.results where name like '%_c'),
-- res_exploit as (select id, name, formula.sum_incert((co2_eq).val, (co2_eq).incert) as co2_eq from exploit group by id, name),
-- res_constr as (select id, name, formula.sum_incert((co2_eq).val, (co2_eq).incert) as co2_eq from constr group by id, name )

-- select ___.results.id, ___.bloc.name, model, jsonb_build_object(
--     'data', jsonb_agg(
--         jsonb_build_object(
--             'name', ___.results.name,
--             'formula', ___.results.formula,
--             'result', ___.add(___.results.result_ss_blocs, ___.results.result_ss_blocs_intrant),
--             'co2_eq', ___.results.co2_eq, 
--             'detail', ___.results.detail_level, 
--             'unknown', ___.results.unknowns,
--             'in use', case when ___.results.id = in_use.id and ___.results.name = in_use.name 
--             and ___.results.detail_level = in_use.detail_level then true else false end
--         )
--         )
--     ) as res, 
--     row(max((res_exploit.co2_eq).val), max((res_exploit.co2_eq).incert))::___.res as co2_eq_e, -- il fallait juste une fonction d'aggrégat
--     row(max((res_constr.co2_eq).val), max((res_constr.co2_eq).incert))::___.res as co2_eq_c
-- from ___.results
-- join ___.bloc on ___.bloc.id = ___.results.id
-- left join in_use on ___.results.id = in_use.id and 
-- ___.results.name = in_use.name and ___.results.detail_level = in_use.detail_level
-- left join res_exploit on ___.results.id = res_exploit.id and ___.results.name = res_exploit.name
-- left join res_constr on ___.results.id = res_constr.id and ___.results.name = res_constr.name
-- -- where ___.results.formula is not null 
-- group by ___.results.id, model, ___.bloc.name;


-- with 
-- useable as (select * from ___.results where val is not null and formula is not null), 
-- unsuable as (select * from ___.results where val is null and formula is not null), 
-- norm_lvl_max as (select id, name, max(detail_level) as max_lvl from useable where detail_level < 6 group by id, name), 
-- in_use as (select distinct useable.id, useable.name, useable.detail_level, useable.formula, co2_eq 
-- from useable
-- join norm_lvl_max on useable.id = norm_lvl_max.id and useable.name = norm_lvl_max.name
-- where ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null 
-- and (useable.detail_level = norm_lvl_max.max_lvl or useable.detail_level = 6)
-- ),
-- results as (select id, name, co2_eq from ___.results), 
-- exploit as (select distinct id, name, co2_eq from ___.results where name like '%_e'), 
-- constr as (select distinct id, name, co2_eq from ___.results where name like '%_c'),
-- res_exploit as (select id, name, formula.sum_incert((co2_eq).val, (co2_eq).incert) as co2_eq from exploit group by id, name),
-- res_constr as (select id, name, formula.sum_incert((co2_eq).val, (co2_eq).incert) as co2_eq from constr group by id, name )
-- select array_agg(res_exploit.id)
-- from ___.results
-- join ___.bloc on ___.bloc.id = ___.results.id
-- left join in_use on ___.results.id = in_use.id and 
-- ___.results.name = in_use.name and ___.results.detail_level = in_use.detail_level
-- left join res_exploit on ___.results.id = res_exploit.id and ___.results.name = res_exploit.name
-- left join res_constr on ___.results.id = res_constr.id and ___.results.name = res_constr.name
-- -- where ___.results.formula is not null 
-- group by ___.results.id, model, ___.bloc.name;


-- with results as (
--     select name, co2_eq 
--     from ___.results where id = any(array[5, 6]) and name = any(array['n2o_c', 'n2o_e', 'ch4_c', 'ch4_e', 'co2_c', 'co2_e']) 
-- ), 
-- exploit as (select distinct name, co2_eq from results where name like '%_e'),
-- constr as (select distinct name, co2_eq from results where name like '%_c')
-- -- select * 
-- select jsonb_build_object(
--     'co2_eq_e', formula.sum_incert((exploit.co2_eq).val, (exploit.co2_eq).incert),
--     'co2_eq_c', formula.sum_incert((constr.co2_eq).val, (constr.co2_eq).incert)
-- ) 
-- from exploit
-- full join constr on exploit.name = constr.name;