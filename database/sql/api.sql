------------------------------------------------------------------------------------------------
-- Template
------------------------------------------------------------------------------------------------

create extension if not exists pgrouting;

create or replace function create_template()
returns varchar
language sql volatile
as
$template$

drop schema if exists template cascade;

create schema template;

comment on schema template is 'temporary schema for template generating functions. dropped at the end of this script';


------------------------------------------------------------------------------------------------
-- Dynamic queries for inherited objects view / functions and triggers                        --
------------------------------------------------------------------------------------------------

create function template.view_statement(
    concrete varchar,
    abstract varchar default null,
    additional_columns varchar[] default '{}'::varchar[],
    additional_join varchar default null,
    additional_union varchar default null,
    specific_geom varchar default null,
    specific_columns json default '{}'::json
    )
returns varchar
language sql stable as
$$
    with pk as (
        select string_agg('a.'||kcu.column_name||'=c.'||kcu.column_name, ' and ') as whr,
               string_agg('c.'||kcu.column_name, '||''_''||') as _id
        from information_schema.table_constraints tco
        join information_schema.key_column_usage kcu
            on kcu.constraint_name = tco.constraint_name
            and kcu.constraint_schema = tco.constraint_schema
            and kcu.constraint_name = tco.constraint_name
        where tco.constraint_type = 'PRIMARY KEY'
        and kcu.constraint_schema = '___' and kcu.table_name = concrete||coalesce('_'||abstract, '')
        and not kcu.column_name ~ '^_.*'
    ),
    concrete_cols as (
        select column_name, data_type
        from information_schema.columns
        where table_schema = '___'
        and table_name = concrete||coalesce('_'||abstract, '')
        and not column_name ~ '^_.*'
    ),
    abstract_cols as (
        select column_name
        from information_schema.columns
        where table_schema = '___'
        and table_name = abstract
        and not column_name ~ '^_.*'
        except
        select column_name from concrete_cols
    )
    select 'create view api.'||concrete||coalesce('_'||abstract, '')||' as '||
        'select '||array_to_string(array_agg(column_name)||additional_columns::text[], ', ')||' '||
        'from ___.'||concrete||coalesce('_'||abstract, '')||' as c '||
        coalesce('join ___.'||abstract||' as a on '||whr, '')||
        coalesce(' '||additional_join, '')||
        coalesce(' '||additional_union, '')
    from (
        select case
            when data_type = 'ARRAY' then ('c.'||column_name||' as '||column_name)
            when column_name in (select key from json_each_text(specific_columns)) then (specific_columns::json->>column_name||' as '||column_name)
            else 'c.'||column_name end
        as column_name from concrete_cols
        union all
        select case
            when column_name = 'geom' then coalesce(specific_geom||' as geom', 'a.geom')
            else 'a.'||column_name end as column_name from abstract_cols ) t
    cross join pk
    group by whr, _id
    ;
$$
;

create function template.view_default_statement(concrete varchar, abstract varchar default null)
returns setof varchar
language sql stable as
$$
    select 'alter view api.'||concrete||coalesce('_'||abstract, '')||' alter column '||column_name||' set default '||column_default
    from information_schema.columns
    where table_schema = '___'
    and table_name in (abstract, concrete||coalesce('_'||abstract, ''))
    and not column_name ~ '^_.*'
    and column_default is not null
    ;
$$
;

create function template.insert_statement(tablename varchar, concrete varchar default null)
returns varchar
language sql stable as
$$
    select 'insert into ___.'||tablename||'('||string_agg(column_name, ', ')||') '||
           'values ('||string_agg('new.'||column_name, ', ')||') '
    from information_schema.columns
    where table_schema = '___'
    and table_name = tablename
    ;
$$
;

create function template.update_statement(tablename varchar)
returns varchar
language sql stable as
$$
    with pk as (
        select string_agg(kcu.column_name||'=old.'||kcu.column_name, ' and ') as whr
        from information_schema.table_constraints tco
        join information_schema.key_column_usage kcu
            on kcu.constraint_name = tco.constraint_name
            and kcu.constraint_schema = tco.constraint_schema
            and kcu.constraint_name = tco.constraint_name
        where tco.constraint_type = 'PRIMARY KEY'
        and kcu.constraint_schema = '___' and kcu.table_name = tablename
        and not kcu.column_name  ~ '^_.*'
    )
    select 'update ___.'||tablename||' '||
           'set '||string_agg(column_name||'='||'new.'||column_name, ', ')||' '||
           'where '||whr
    from information_schema.columns
    cross join pk
    where table_schema = '___'
    and table_name = tablename
    and not column_name ~ '^_.*'
    group by whr
    ;
$$
;

create function template.delete_statement(tablename varchar)
returns varchar
language sql stable as
$$
    select 'delete from ___.'||tablename||' where '||string_agg(kcu.column_name||'=old.'||kcu.column_name, ' and ') as whr
    from information_schema.table_constraints tco
    join information_schema.key_column_usage kcu
        on kcu.constraint_name = tco.constraint_name
        and kcu.constraint_schema = tco.constraint_schema
        and kcu.constraint_name = tco.constraint_name
    where tco.constraint_type = 'PRIMARY KEY'
    and kcu.constraint_schema = '___'
    and kcu.table_name = tablename
    and not column_name ~ '^_.*'
    ;
$$
;

create function template.basic_function_statement(
    table_name varchar,
    cannot_delete boolean default False,
    start_section varchar default null
    )
returns varchar
language plpgsql stable as
$$
begin
    return 'create function api.'||table_name||E'_instead_fct()\n'||
    E'returns trigger \n'||
    E'language plpgsql volatile security definer as\n'||
    E'$fct$\n'||
    E'declare\n'||
    E'    overloaded_geom geometry; -- used in start_section to modify geom type\n'||
    E'begin\n'||
    coalesce(start_section, '')||
    E'    if tg_op = ''INSERT'' then\n'||
    E'        '||template.insert_statement(table_name)||E';\n'||
    E'        return new;\n'||
    E'    elsif tg_op = ''UPDATE'' then\n'||
    E'        '||template.update_statement(table_name)||E';\n'||
    E'        return new;\n'||
    E'    elsif tg_op = ''DELETE'' then\n'||
    case when cannot_delete then
    E'        raise notice ''cannot delete from table '||table_name||E''';\n'
    else
    E'        '||template.delete_statement(table_name)||E';\n'
    end||
    E'        return old;\n'||
    E'    end if;\n'||
    E'end;\n'||
    E'$fct$\n';
end;
$$
;

create function template.inherited_function_statement(
    concrete varchar,
    abstract varchar,
    start_section varchar default null,
    after_insert_section varchar default null,
    after_update_section varchar default null
    )
returns varchar
language plpgsql stable as
$$
begin
    raise notice '%', template.insert_statement(concrete||'_'||abstract||'_config', concrete);
    raise notice '%', template.update_statement(concrete||'_'||abstract||'_config');
    return 'create function api.'||concrete||'_'||abstract||E'_instead_fct()\n'||
    E'returns trigger \n'||
    E'language plpgsql volatile security definer as\n'||
    E'$fct$\n'||
    E'declare\n'||
    E'    overloaded_geom geometry; -- used in start_section to modify geom type\n'||
    E'begin\n'||
    coalesce(start_section, '')||
    E'    if tg_op = ''INSERT'' then\n'||
    E'        '||template.insert_statement(abstract, concrete)||E';\n'||
    E'        '||template.insert_statement(concrete||'_'||abstract, concrete)||E';\n'||
    E'        '||coalesce(after_insert_section, '')||
    E'        return new;\n'||
    E'    elsif tg_op = ''UPDATE'' then\n'||
    E'        '||template.update_statement(abstract)||E';\n'||
    E'        if ___.current_config() is null then\n'||
    E'            '||template.update_statement(concrete||'_'||abstract)||E';\n'||
    E'        else\n'||
    E'            '||replace(template.insert_statement(concrete||'_'||abstract||'_config', concrete), 'new.config', 'api.current_config()')||
    E'            on conflict on constraint '||concrete||'_'||abstract||E'_config_pkey do\n'||
    E'            '||replace(replace(regexp_replace(template.update_statement(concrete||'_'||abstract), ' where .*', ''), ' ___.'||concrete||'_'||abstract, ''), 'new.config', 'api.current_config()')||E';\n'||
    E'        end if;\n'||
    coalesce(after_update_section, '')||
    E'        return new;\n'||
    E'    elsif tg_op = ''DELETE'' then\n'||
    E'        '||template.delete_statement(abstract)||E';\n'||
    E'        '||template.delete_statement(concrete||'_'||abstract)||E';\n'|| -- inutile, le abrait fait référence au concret avec 'on delete cascade'
    E'        return old;\n'||
    E'    end if;\n'||
    E'end;\n'||
    E'$fct$\n';
end;
$$
;

create function template.trigger_statement(concrete varchar, abstract varchar default null)
returns varchar
language sql stable as
$$
    select
    E'create trigger '||concrete||coalesce('_'||abstract, '')||E'_instead_trig\n'||
    E'instead of insert or update or delete on api.'||concrete||coalesce('_'||abstract, '')||E'\n'||
    E'for each row execute procedure api.'||concrete||coalesce('_'||abstract, '')||E'_instead_fct()\n';
$$
;

create function template.basic_view(
    table_name varchar,
    additional_columns varchar[] default '{}'::varchar[],
    additional_join varchar default null,
    additional_union varchar default null,
    with_trigger boolean default False,
    cannot_delete boolean default False,
    specific_geom varchar default null,
    specific_columns json default '{}'::json,
    start_section varchar default ''
    )
returns varchar
language plpgsql volatile as
$$
declare
    s varchar;
begin
    raise notice '%', template.view_statement(table_name, additional_columns => additional_columns, additional_join => additional_join, additional_union => additional_union, specific_geom => specific_geom, specific_columns => specific_columns);
    execute template.view_statement(table_name, additional_columns => additional_columns, additional_join => additional_join, additional_union => additional_union, specific_geom => specific_geom, specific_columns => specific_columns);
    for s in select * from template.view_default_statement(table_name) loop
        raise notice '%', s;
        execute s;
    end loop;
    if with_trigger then
        raise notice '%', template.basic_function_statement(table_name, cannot_delete=>cannot_delete);
        execute template.basic_function_statement(table_name, cannot_delete=>cannot_delete, start_section=>start_section);
        raise notice '%', template.trigger_statement(table_name);
        execute template.trigger_statement(table_name);
    end if;

    return 'CREATE BASIC VIEW api.'||table_name;
end;
$$
;

create function template.inherited_view(
    concrete varchar,
    abstract varchar,
    additional_columns varchar[] default '{}'::varchar[],
    additional_join varchar default null,
    specific_geom varchar default null,
    specific_columns json default '{}'::json,
    start_section varchar default '',
    after_insert_section varchar default null,
    after_update_section varchar default ''
    )
returns varchar
language plpgsql volatile as
$$
declare
    s varchar;
begin
    -- raise notice '%', template.view_statement(concrete, abstract, additional_columns, additional_join, specific_geom, specific_columns);
    additional_join := coalesce(additional_join, '')||format(' where c.id not in (select g.id from ___.%s_%s_config g where g.config=___.current_config())', concrete, abstract);

    s := template.view_statement(concrete, abstract, additional_columns => additional_columns, additional_join => additional_join, specific_geom => specific_geom, specific_columns => specific_columns);
    -- raise notice '%', s;
    -- add configuration

    s := s||
        regexp_replace(
        regexp_replace(
        regexp_replace(
        s, 'create view [^ ]+ as select ', ' union all select '),
        concrete||'_'||abstract, concrete||'_'||abstract||'_config'),
        ' where .*', ' where c.config=___.current_config()');
    
    -- raise notice '%', s;
    execute s;

    for s in select * from template.view_default_statement(concrete, abstract) loop
        -- raise notice '%', s;
        execute s;
    end loop;
    -- raise notice '%', template.inherited_function_statement(concrete, abstract);
    execute template.inherited_function_statement(concrete, abstract, start_section=>start_section,
     after_update_section=>after_update_section, after_insert_section=>after_insert_section);
    -- raise notice '%', template.trigger_statement(concrete, abstract);
    execute template.trigger_statement(concrete, abstract);

    return 'CREATE INHERITED VIEW api.'||concrete||'_'||abstract;
end;
$$
;

create or replace function template.bloc_view(concrete varchar, abstract varchar, shape varchar)
returns varchar
language plpgsql as
$fonction$
-- Create a view api for a bloc with the section to update the links and the relationship between blocs
DECLARE
    query text;
begin 
    query := E'select template.inherited_view(''' || concrete || ''', ''' || abstract || ''', specific_geom => ' ||
    E'''ST_Force2D(a.geom)::geometry('|| shape ||',' || (select srid from ___.metadata) || ')'',' ||
    E'after_update_section => $$\n' ||
    E'    if not St_equals(old.geom, new.geom) then\n' ||
    E'        update ___.link set geom = st_setpoint(geom, 0, new.geom) where up = new.id;\n' ||
    E'        update ___.link set geom = st_setpoint(geom, -1, new.geom) where down = new.id;\n' ||
    E'    end if;\n' ||
    E'$$, \n' ||
    E'after_insert_section => $$\n' ||
    E'      perform api.update_links(new.id, ''' || shape || ''', new.geom, new.model);' ||
    E'$$, \n' ||
    E'start_section => $$\n' ||
    E'    if tg_op = ''INSERT'' or tg_op = ''UPDATE'' then\n' ||
    E'        new.ss_blocs := api.find_ss_blocs(new.id, new.geom, new.model);\n' ||
    E'        new.sur_bloc := api.find_sur_bloc(new.id, new.geom, new.model);\n' ||
    E'    end if;\n' ||
    E'    if tg_op = ''DELETE'' then\n' ||
    E'        update ___.bloc set ss_blocs = array_remove(ss_blocs, old.id) where id = old.sur_bloc; -- remove the bloc from the list of sub-blocs of the sur-bloc\n' ||
    E'        update ___.bloc set sur_bloc = api.find_sur_bloc(old.id, old.geom, old.model) where sur_bloc = old.id; -- update the sur-bloc\n' ||
    E'    end if;\n' ||
    E'$$);';
    -- raise notice '%', query;
    execute query;
    return 'CREATE VIEW ' || concrete || '_' || abstract;
end;
$fonction$;

create function template.execute_with_srid(query varchar, srid integer)
returns varchar
language plpgsql volatile as
$$
begin
    --raise notice '%', replace(query, '$SRID', srid::varchar);
    execute replace(query, '$SRID', srid::varchar);
    return replace(query, '$SRID', srid::varchar);
end;
$$
;

create function template.create_configured_view()
returns void
language plpgsql volatile as
$$
declare
    sql varchar;
    c varchar;
    row_diff_join varchar;
    delete_statements varchar;
    update_statements varchar;
begin
    sql := E'create view api.configured as \n'||
           E'with diff as (\n';
    delete_statements := '';
    update_statements := '';

    row_diff_join = $sql$
            join lateral (
                select
                --json_object_agg(COALESCE(orig.key, config.key), ('{"default": '||orig.value||', "config": '||config.value||'}')::jsonb) as txt
                string_agg(COALESCE(orig.key, config.key)||' '||coalesce(orig.value, 'null')||' -> '||coalesce(config.value, 'null'), ', ') as difference
                from json_each_text(row_to_json(o)) orig
                join json_each_text(row_to_json(c)) config on config.key = orig.key
                where config.value is distinct from orig.value
                ) d on true
    $sql$;

    for c in select name from ___.type_node
    loop
        raise notice '%', c;
        sql := sql || format($sql$
            select '%1$s_node' as type, n.name, c.config, d.difference, n.geom
            from ___.%1$s_node_config c
            join ___.%1$s_node o on o.id=c.id
            join ___.node n on n.id=c.id %2$s union all $sql$, c, row_diff_join);
        delete_statements := delete_statements ||
            'delete from ___.'||c||E'_node_config where name=old.name and config=old.config;\n';
        update_statements := update_statements ||
            'update ___.'||c||E'_node_config set config=new.config where name=old.name and config=old.config;\n';
    end loop;

    for c in select name from ___.type_singularity
    loop
        raise notice '%', c;
        sql := sql || format($sql$
            select '%1$s_singularity' as type, c.name, c.config, d.difference, n.geom
            from ___.%1$s_singularity_config c
            join ___.%1$s_singularity o on o.id=c.id
            join ___.node n on n.id=c.id %2$s union all $sql$, c, row_diff_join);
        delete_statements := delete_statements ||
            'delete from ___.'||c||E'_singularity_config where name=old.name and config=old.config;\n';
        update_statements := update_statements ||
            'update ___.'||c||E'_singularity_config set config=new.config where name=old.name and config=old.config;\n';
    end loop;

    for c in select name from ___.type_link
    loop
        sql := sql || format($sql$
            select '%1$s_link' as type, l.name, c.config, d.difference, st_lineinterpolatepoint(l.geom, .5) geom
            from ___.%1$s_link_config c
            join ___.%1$s_link o on o.id=c.id
            join ___.link l on l.id=c.id %2$s union all $sql$, c, row_diff_join);
        delete_statements := delete_statements ||
            'delete from ___.'||c||E'_link_config where name=old.name and config=old.config;\n';
        update_statements := update_statements ||
            'update ___.'||c||E'_link_config set config=new.config where name=old.name and config=old.config;\n';
    end loop;

    sql := regexp_replace(sql, 'union all $', '');
    sql := sql || format(') select row_number() over(order by name, config) as id, type, name, config, difference, st_force2d(geom)::geometry(POINT, %s) geom from diff', (select srid from ___.metadata));

    execute sql;

    execute format($sql$
        create function api.configured_instead_fct()
        returns trigger
        language plpgsql volatile security definer as
        $fct$
        begin
            if tg_op = 'INSERT' then
                raise 'no insert allowed';
                return new;
            elsif tg_op = 'UPDATE' then
                %s
                return new;
            elsif tg_op = 'DELETE' then
                %s
                return old;
            end if;
        end;
        $fct$
        $sql$, update_statements, delete_statements);

    create trigger configured_instead_trig
    instead of insert or delete or update on api.configured
    for each row execute procedure api.configured_instead_fct();

end;
$$
;

select 'ok'::varchar;
$template$
;

select create_template();


------------------------------------------------------------------------------------------------
-- Views api
------------------------------------------------------------------------------------------------


drop schema if exists api cascade;
create schema api;


-- fonction pour trouver les sous-blocs d'un bloc
create or replace function api.find_ss_blocs(id_sur_bloc integer, g geometry, model_name varchar)
returns integer[]
language plpgsql
as $$
declare
    ss_blocs_array integer[];
Begin 
    select array_agg(id) into ss_blocs_array
    from ___.bloc
    where st_within(___.bloc.geom, g) and ___.bloc.model = model_name ;

    -- On enlève les sous-blocs de sous-blocs
    ss_blocs_array := array(
        WITH b AS (
            SELECT id, sur_bloc
            FROM ___.bloc
        )
        SELECT id
        FROM unnest(ss_blocs_array) AS id
        WHERE id IN (
            SELECT b.id
            FROM b
            WHERE b.sur_bloc is null or not b.sur_bloc = ANY(ss_blocs_array)
        )
    );
    raise notice 'ss_blocs_array := %', ss_blocs_array;
    update ___.bloc set sur_bloc = id_sur_bloc where id = any(ss_blocs_array);

    return ss_blocs_array;
end ;
$$; 

-- Fonction pour trouver le sur-bloc d'un bloc que l'on ajoute à la view et update tout ça
create or replace function api.find_sur_bloc(id_ss_bloc integer, g geometry, model_name varchar)
returns integer
language plpgsql
as $$
declare
    sur_bloc_id integer;
begin
    select id into sur_bloc_id
    from ___.bloc
    where st_within(g, ___.bloc.geom) and ___.bloc.model = model_name
    order by st_area(___.bloc.geom) asc
    limit 1;
    update ___.bloc set ss_blocs = array_append(ss_blocs, id_ss_bloc) where id = sur_bloc_id; 
    return sur_bloc_id;
end;
$$;

create or replace function api.update_links(link_id integer, shape ___.geo_type, g geometry, model_name varchar)
returns void
language plpgsql
as $$
declare
    ups integer;
    downs integer;
    point_up geometry;
    point_down geometry;
begin 
    if shape = 'LineString' then
        point_up := st_startpoint(g);
        point_down := st_endpoint(g);
        for ups in (select id from ___.bloc where st_intersects(geom, point_up) 
            and model = model_name and not id = link_id) 
            loop
            insert into ___.link (up, down) values (ups, link_id);
        end loop;
        for downs in (select id from ___.bloc where st_intersects(geom, point_down) 
            and model = model_name and not id = link_id) 
            loop
            insert into ___.link (up, down) values (link_id, downs);
        end loop;
    else 
        for downs in (select id
        from ___.bloc where st_intersects(st_startpoint(geom), g) and model = model_name 
        and not id = link_id and ___.bloc.shape = 'LineString') loop 
            insert into ___.link (up, down) values (link_id, downs);
        end loop;
        for ups in (select id
        from ___.bloc where st_intersects(st_endpoint(geom), g) and model = model_name
        and not id = link_id and ___.bloc.shape = 'LineString') loop 
            insert into ___.link (up, down) values (ups, link_id);
        end loop;
    end if;

end;
$$;

------------------------------------------------------------------------------------------------
-- Views on blocs
------------------------------------------------------------------------------------------------

select template.bloc_view('test', 'bloc', 'Polygon') ; 

select template.bloc_view('piptest', 'bloc', 'LineString') ;

select template.basic_view('sorties');
------------------------------------------------------------------------------------------------
-- Metadata
------------------------------------------------------------------------------------------------

select template.basic_view('metadata');

------------------------------------------------------------------------------------------------
-- MODELS                                                                                     --
------------------------------------------------------------------------------------------------

select template.basic_view('model');

------------------------------------------------------------------------------------------------
-- Config 
------------------------------------------------------------------------------------------------

create function api.current_config()
returns varchar
language sql stable security definer as
$$
    select ___.current_config();
$$
;

create function api.set_current_config(name varchar)
returns void
language sql volatile security definer as
$$
    insert into ___.user_configuration(user_, config) values (session_user, name)
    on conflict on constraint user_configuration_pkey do
    update set config=name;
$$
;

------------------------------------------------------------------------------------------------
-- Add future bloc 
------------------------------------------------------------------------------------------------

create or replace function api.add_new_bloc(concrete varchar, abstract varchar, shape varchar)
returns varchar
language plpgsql as 
$$
begin
    if not exists (
        select 1 
        from information_schema.views 
        where table_schema = 'api' 
        and table_name = concrete || '_' || abstract
    ) then 
        perform template.bloc_view(concrete, abstract, shape);
        return 'Bloc ' || concrete || '_' || abstract || ' added';
    end if;
    return 'Bloc ' || concrete || '_' || abstract || ' already exists';
end; 
$$;


