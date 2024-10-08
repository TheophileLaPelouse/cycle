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
            when column_name = 'geom' then coalesce(specific_geom||' as geom', 'c.geom')
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
    return 'create or replace function api.'||table_name||E'_instead_fct()\n'||
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
    -- raise notice '%', template.insert_statement(concrete||'_'||abstract||'_config', concrete);
    -- raise notice '%', template.update_statement(concrete||'_'||abstract||'_config');
    return 'create or replace function api.'||concrete||'_'||abstract||E'_instead_fct()\n'||
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
    -- raise notice '%', template.view_statement(table_name, additional_columns => additional_columns, additional_join => additional_join, additional_union => additional_union, specific_geom => specific_geom, specific_columns => specific_columns);
    execute template.view_statement(table_name, additional_columns => additional_columns, additional_join => additional_join, additional_union => additional_union, specific_geom => specific_geom, specific_columns => specific_columns);
    for s in select * from template.view_default_statement(table_name) loop
        -- raise notice '%', s;
        execute s;
    end loop;
    if with_trigger then
        -- raise notice '%', template.basic_function_statement(table_name, cannot_delete=>cannot_delete);
        execute template.basic_function_statement(table_name, cannot_delete=>cannot_delete, start_section=>start_section);
        -- raise notice '%', template.trigger_statement(table_name);
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
    -- raise notice '%', template.inherited_function_statement(concrete, abstract, start_section=>start_section,
    --  after_update_section=>after_update_section, after_insert_section=>after_insert_section);
    execute template.inherited_function_statement(concrete, abstract, start_section=>start_section,
     after_update_section=>after_update_section, after_insert_section=>after_insert_section);
    -- raise notice '%', template.trigger_statement(concrete, abstract);
    execute template.trigger_statement(concrete, abstract);

    return 'CREATE INHERITED VIEW api.'||concrete||'_'||abstract;
end;
$$
;

create or replace function template.bloc_view(concrete varchar, abstract varchar, shape varchar, 
additional_columns varchar default null, additional_join varchar default null)
returns varchar
language plpgsql as
$fonction$
-- Create a view api for a bloc with the section to update the links and the relationship between blocs
DECLARE
    query text;
begin 
    query := E'select template.inherited_view(''' || concrete || ''', ''' || abstract || ''', specific_geom => ' ||
    E'''c.geom::geometry('|| shape ||',' || (select srid from ___.metadata) || ')'',' ||
    coalesce(E'additional_columns => '''||additional_columns||''',', '') ||
    coalesce(E'additional_join => '''||additional_join||''',', '') ||
    E'after_update_section => $$\n' ||
    E'    if not St_equals(old.geom, new.geom) then\n' ||
    E'        update ___.link set geom = st_setpoint(geom, 0, new.geom) where up = new.id;\n' ||
    E'        update ___.link set geom = st_setpoint(geom, -1, new.geom) where down = new.id;\n' ||
    E'    end if;\n' ||
    E'    perform api.calculate_bloc(new.id, new.model);' ||
    E'    perform api.update_results_ss_bloc(new.id, new.sur_bloc);' ||
    E'$$, \n' ||
    E'after_insert_section => $$\n' ||
    E'      perform api.update_links(new.id, ''' || shape || ''', new.geom, new.model);' ||
    E'      perform api.update_calc_bloc(new.id, new.model);' ||
    E'      perform api.calculate_bloc(new.id, new.model);' ||
    E'      perform api.get_results_ss_bloc(new.id);' ||
    E'      perform api.update_results_ss_bloc(new.id, new.sur_bloc);' ||
    E'$$, \n' ||
    E'start_section => $$\n' ||
    E'    if tg_op = ''INSERT'' or tg_op = ''UPDATE'' then\n' ||
    E'        new.b_type := '''||concrete||'''::___.bloc_type ;' ||
    E'        new.geom_ref := api.make_polygon(new.geom, '''||shape||''');' ||
    E'        new.ss_blocs := api.find_ss_blocs(new.id, new.geom_ref, new.model);\n' ||
    E'        new.sur_bloc := api.find_sur_bloc(new.id, new.geom_ref, new.model);\n' ||
    E'    end if;\n' ||
    E'    if tg_op = ''DELETE'' then\n' ||
    E'        perform api.update_calc_bloc(old.id, old.model, true);' ||
    E'        perform api.update_results_ss_bloc(old.id, old.sur_bloc, true);' ||
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

-- fonction pour créer un polygon dans la table bloc qui correspond au point, à la ligne ou polygon dans table concrete
create or replace function api.make_polygon(g geometry, shape ___.geo_type)
returns geometry('POLYGON', 2154)
language plpgsql
as $$
declare 
    poly_text varchar ;
begin
    -- raise notice 'making polygon';
    if shape = 'Point' then
        -- poly_text := 'POLYGON(('||st_x(g)||' '||st_y(g)||', '||st_x(g)||' '||st_y(g)||', '||st_x(g)||' '||st_y(g)||', '||st_x(g)||' '||st_y(g)||'))';
        -- return st_geomfromtext(poly_text, 2154);
        return st_buffer(g, 0.000001) ;
    elsif shape = 'LineString' then
        -- poly_text := 'POLYGON(('||st_x(st_startpoint(g))||' '||st_y(st_startpoint(g))||', '||st_x(st_endpoint(g))||' '||st_y(st_endpoint(g))||', '||st_x(st_endpoint(g))||' '||st_y(st_endpoint(g))||', '||st_x(st_startpoint(g))||' '||st_y(st_startpoint(g))||'))';
        -- return st_geomfromtext(poly_text, 2154);
        return st_buffer(g, 0.000001) ;
    elsif shape = 'Polygon' then
        return g;
    end if;
    -- raise notice 'polygon made';
end;
$$;

-- fonction pour trouver les sous-blocs d'un bloc
create or replace function api.find_ss_blocs(id_sur_bloc integer, g geometry, model_name varchar)
returns integer[]
language plpgsql
as $$
declare
    ss_blocs_array integer[];
Begin 
    -- raise notice 'finding ss_blocs';
    select array_agg(id) into ss_blocs_array
    from ___.bloc
    where st_within(___.bloc.geom_ref, g) and ___.bloc.model = model_name and not ___.bloc.id = id_sur_bloc;

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
    -- raise notice 'ss_blocs_array := %', ss_blocs_array;
    update ___.bloc set sur_bloc = id_sur_bloc where id = any(ss_blocs_array);
    -- raise notice 'ss_blocs found';
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
    -- raise notice 'finding sur_bloc';
    select id into sur_bloc_id
    from ___.bloc
    where st_within(g, ___.bloc.geom_ref) and ___.bloc.model = model_name and not ___.bloc.id = id_ss_bloc
    order by st_area(___.bloc.geom_ref) asc
    limit 1;
    update ___.bloc set ss_blocs = array_append(ss_blocs, id_ss_bloc) where id = sur_bloc_id and not id_ss_bloc = any(ss_blocs); 
    -- raise notice 'sur_bloc found';
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
    text_geo varchar;
    point_up geometry;
    point_down geometry;
begin 
    -- raise notice 'updating links';
    if shape = 'LineString' then
        point_up := st_startpoint(g);
        point_down := st_endpoint(g);
-- Y'a peut être possibilité de faire tout en une seule query mais j'ai pas réussi
        for ups in (
            with possible_ids as (select id, geom_ref from ___.bloc 
            where model = model_name and not id = link_id and not st_within(g, geom_ref)
            )
            select id from possible_ids where st_intersects(geom_ref, point_up)
            )
        loop
            insert into ___.link (up, down, model) values (ups, link_id, model_name);
        end loop;
        
        for downs in (
            with possible_ids as (select id, geom_ref from ___.bloc 
            where model = model_name and not id = link_id and not st_within(g, geom_ref)
            )
            select id from possible_ids where st_intersects(geom_ref, point_down)
            )
        loop
            insert into ___.link (up, down, model) values (link_id, downs, model_name);
        end loop;

    else 
        -- link_id n'est plus l'id d'un lien
        -- (dp).path[1] renvoie le numéro de la ligne dans le multipoint et d'après la fonction api.make_polygon,
        -- le premier point dans un linestrig est le startpoint et le deuxième le endpoint  
    for downs in (
        with dumps as (select id, st_dump(st_points(geom_ref)) as dp
        from ___.bloc where model = model_name and ___.bloc.shape = 'LineString'
        ),
        startpoints as (select id, (dp).geom as geo from dumps where (dp).path[1] = 1
        )
        select id from startpoints where st_intersects(geo, g)
        )
    loop
        insert into ___.link (up, down, model) values (link_id, downs, model_name);
    end loop;
    
    for ups in (
        with dumps as (select id, st_dump(st_points(geom_ref)) as dp
        from ___.bloc where model = model_name and ___.bloc.shape = 'LineString'
        ),
        endpoints as (select id, (dp).geom as geo from dumps where (dp).path[1] = 2
        )
        select id from endpoints where st_intersects(geo, g)
        )
    loop
        insert into ___.link (up, down, model) values (ups, link_id, model_name);
    end loop;    

    end if;
    -- raise notice 'links updated';
end;
$$;

-- Maintenant on ajoute les fonctions qui vont adapter input_output comme il faut 
-- On veut que quand on ajoute une formules, les données de input_output soient adaptées + ajouter des colonnes dans les blocs

create or replace function api.add_formula_to_input_output(b_type_arg ___.bloc_type, formula_name varchar)
returns boolean
language plpgsql
as $$
declare
    f_inputs varchar[];
    f varchar;
    f_name varchar[] ;
    flag_alreadyin boolean;
    flag boolean;
    query text;
begin 

    select default_formulas into f_name
    from api.input_output
    where b_type = b_type_arg;

    select into flag_alreadyin exists (
        select 1
        from api.input_output
        where b_type = b_type_arg and formula_name = any(default_formulas)
    );

    if not exists (
        select 1
        from api.formulas
        where name = formula_name )
    then
        raise notice 'formula % not found', formula_name;
        flag = false ; 
    elseif flag_alreadyin then 
        raise notice 'formula % already in', formula_name;
        flag = false ;
    else 
        select formula into f
        from api.formulas
        where name = formula_name;
-- operators = ['+', '-', '*', '/', '^', '(', ')']
-- pat = '['+re.escape(''.join(operators))+']'
        select array_agg(trim(both ' ' from elem))
        into f_inputs
        from unnest(
            regexp_split_to_array(
                regexp_replace(f, '^[^=]*=', ''), 
                '[\+\-\*\/\^\(\)]'
            )
        ) as elem;

        -- Update input_output entrees (donc si on ajoute ou change une formule et que ça rajoute des valeurs ce ne sera pas des sorties (ce qui fait sens en vrai))
        with old_inputs as (
            select inputs
            from api.input_output
            where b_type = b_type_arg
        ), 
        old_outputs as (
            select outputs
            from api.input_output
            where b_type = b_type_arg
        ),
        inp_out as (
            select array_cat(inputs, outputs) as olds from old_inputs, old_outputs
        ),
        new_inputs as (
            select count(inp) as c from unnest(f_inputs) as inp
            where inp not in (select unnest(olds) from inp_out)
        )
        select c=0 into flag from new_inputs; 

    end if;
    if flag then 
        update ___.input_output
        set default_formulas = array_append(default_formulas, formula_name)
        where b_type = b_type_arg;

        -- On rajoute la formule dans les blocs 
        query := 'update ___.'||b_type_arg||'_bloc set formula_name = array_append(formula_name, '''||formula_name||''')';
        execute query;
        -- On change les valeurs par défaults de la colonne formula_name
        query := 'alter view api.'||b_type_arg||'_bloc alter column formula_name set default array['||coalesce(array_to_string(f_name, ',') || ',', '')||' '''||formula_name||''']';
        -- raise notice '%', query;
        execute query;
    end if ;
    return flag ; 
end ; 
$$;

create or replace function api.trigger_add_formula_to_input_output()
returns trigger 
language plpgsql
as $$
declare 
    formula_to_add varchar[] ; 
    formula varchar ;
begin
    if old.default_formulas is distinct from new.default_formulas 
    and (old.b_type = new.b_type or new.b_type is null) then
        select array_agg(elem) into formula_to_add from unnest(new.default_formulas) as elem
        where elem not in (select unnest(old.default_formulas));

        foreach formula in array formula_to_add
        loop
            perform api.add_formula_to_input_output(old.b_type, formula);
        end loop;
    end if;
    return null;
end;
$$;

------------------------------------------------------------------------------------------------
-- Views on blocs
------------------------------------------------------------------------------------------------

select template.bloc_view('test', 'bloc', 'Polygon') ; 

-- select template.basic_view('test_bloc') ;

select template.bloc_view('piptest', 'bloc', 'LineString') ;



select template.basic_view('sorties');

select template.basic_view('link');

select template.basic_view('bloc');

-- select template.basic_view('input_output') ;

create view api.input_output as 
select * from ___.input_output ; 

create trigger before_update_input_output
instead of update on api.input_output
for each row execute function api.trigger_add_formula_to_input_output();

------------------------------------------------------------------------------------------------
-- Information
------------------------------------------------------------------------------------------------

select template.basic_view('metadata');

select template.basic_view('formulas');

-- select template.basic_view('results') ;

create view api.results as
with ranked_results as (
    select id, formula, name, detail_level, result_ss_blocs, co2_eq,
           row_number() over (partition by id, name order by detail_level desc) as rank,
           max(detail_level) over (partition by id) as max_detail_level
    from ___.results
    where formula is not null
),
in_use as (
    select id, formula, name, detail_level, result_ss_blocs, co2_eq
    from ranked_results
    where (max_detail_level < 6 and rank = 1) or (max_detail_level = 6 and rank <= 2)
),
exploit as (select name, id, co2_eq from in_use where name like '%_e'),
constr as (select name, id, co2_eq from in_use where name like '%_c')
select ___.results.id, ___.bloc.name, model, jsonb_build_object(
    'data', jsonb_agg(
        jsonb_build_object(
            'name', ___.results.name,
            'formula', ___.results.formula,
            'result', ___.results.result_ss_blocs,
            'co2_eq', ___.results.co2_eq, 
            'detail', ___.results.detail_level, 
            'unknown', ___.results.unknowns,
            'in use', case when ___.results.id = in_use.id and ___.results.name = in_use.name 
            and ___.results.detail_level = in_use.detail_level then true else false end
        )
        )
    ) as res, 
    sum(exploit.co2_eq) as co2_eq_e, sum(constr.co2_eq) as co2_eq_c
from ___.results
join ___.bloc on ___.bloc.id = ___.results.id
left join in_use on ___.results.id = in_use.id and 
___.results.name = in_use.name and ___.results.detail_level = in_use.detail_level
left join exploit on ___.results.id = exploit.id and ___.results.name = exploit.name
left join constr on ___.results.id = constr.id and ___.results.name = constr.name
where ___.results.formula is not null 
group by ___.results.id, model, ___.bloc.name;

create or replace function api.get_histo_data(p_model varchar, id_bloc integer default null)
returns jsonb 
language plpgsql
as $$
declare
    query text;
    res jsonb := '{}';
    sur_blocs integer[];
    names varchar[] := array['n2o_c', 'n2o_e', 'ch4_c', 'ch4_e', 'co2_c', 'co2_e'];
    bloc_name varchar;
    sum_values jsonb;
    id_loop integer;
    total_values jsonb;
begin
    if id_bloc is null then
        select into sur_blocs array_agg(id) from ___.bloc where model = p_model and sur_bloc is null;
    else 
        select into sur_blocs array_agg(id) from ___.bloc where model = p_model and sur_bloc = id_bloc;
    end if;

    -- Loop through each bloc id
    if array_length(sur_blocs, 1) = 0 then
        return '{"total": {"ch4_c": 0, "ch4_e": 0, "co2_c": 0, "co2_e": 0, "n2o_c": 0, "n2o_e": 0, "co2_eq_c": 0, "co2_eq_e": 0}';
    end if;

    foreach id_loop in array sur_blocs loop
        -- Get the bloc name
        select into bloc_name name from ___.bloc where id = id_loop;

        if bloc_name != 'link' or bloc_name != 'lien' then 
            -- Calculate the sum of the values for the specified names
            select into sum_values jsonb_build_object(
                'n2o_c', coalesce(sum(case when name = 'n2o_c' then result_ss_blocs end), 0),
                'n2o_e', coalesce(sum(case when name = 'n2o_e' then result_ss_blocs end), 0),
                'ch4_c', coalesce(sum(case when name = 'ch4_c' then result_ss_blocs end), 0),
                'ch4_e', coalesce(sum(case when name = 'ch4_e' then result_ss_blocs end), 0),
                'co2_c', coalesce(sum(case when name = 'co2_c' then result_ss_blocs end), 0),
                'co2_e', coalesce(sum(case when name = 'co2_e' then result_ss_blocs end), 0),
                'co2_eq_e', coalesce(sum(case when name like '%_e' then co2_eq end), 0),
                'co2_eq_c', coalesce(sum(case when name like '%_c' then co2_eq end), 0)
            ) from ___.results where id = id_loop;

            -- Add the result to the JSONB object
            res := jsonb_set(res, array[bloc_name], sum_values, true);
        end if;
    end loop;

    select into total_values jsonb_build_object(
        'n2o_c', coalesce(sum(case when name = 'n2o_c' then result_ss_blocs end), 0),
        'n2o_e', coalesce(sum(case when name = 'n2o_e' then result_ss_blocs end), 0),
        'ch4_c', coalesce(sum(case when name = 'ch4_c' then result_ss_blocs end), 0),
        'ch4_e', coalesce(sum(case when name = 'ch4_e' then result_ss_blocs end), 0),
        'co2_c', coalesce(sum(case when name = 'co2_c' then result_ss_blocs end), 0),
        'co2_e', coalesce(sum(case when name = 'co2_e' then result_ss_blocs end), 0),
        'co2_eq_e', coalesce(sum(case when name like '%_e' then co2_eq end), 0),
        'co2_eq_c', coalesce(sum(case when name like '%_c' then co2_eq end), 0)
    ) from ___.results where id = any(sur_blocs);

    -- Add the total values to the JSONB object
    res := jsonb_set(res, array['total'], total_values, true);

    return res;
end;
$$;
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

create or replace function api.add_new_bloc(concrete varchar, abstract varchar, shape varchar, 
additional_columns varchar default null, additional_join varchar default null)
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
        perform template.bloc_view(concrete, abstract, shape, additional_columns, additional_join);
        return 'Bloc ' || concrete || '_' || abstract || ' added';
    end if;
    return 'Bloc ' || concrete || '_' || abstract || ' already exists';
end; 
$$;

create or replace function api.add_new_formula(formula_name varchar, f varchar, detail integer, com text default null)
returns varchar
language plpgsql as
$$
begin
    if not exists (
        select 1
        from api.formulas
        where name = formula_name )
    then
        insert into api.formulas(name, formula, detail_level, comment) values (formula_name, f, detail, com);
        return 'Formula ' || formula_name || ' added';
    else 
        return 'Formula ' || formula_name || ' already exists';
    end if;
end ;
$$; 

create or replace function api.insert_inp_out(b_type ___.bloc_type, col_name varchar, col_type varchar, col_default varchar, modif varchar, inp_or_out varchar)
returns varchar
language plpgsql as
$$
declare 
    query text;
begin 
    case 
    when modif = 'added' then
        query = 'update  ___.input_output set ' || inp_or_out || 's = array_append('|| inp_or_out ||'s, '''|| col_name || ''') where b_type = '''|| b_type || ''';';
        raise notice '%', query;
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc add column ' || col_name || ' ' || col_type || ' default ' || col_default || ';';
        raise notice '%', query;
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc_config add column ' || col_name || ' ' || col_type || ' default ' || col_default || ';';
        raise notice '%', query;
        execute query;
    when modif = 'remove' then
        query = 'update ___.input_output set ' || inp_or_out || 's = array_remove('|| inp_or_out ||'s, '''|| col_name || ''') where b_type = '''|| b_type || ''';'; 
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc drop column ' || col_name || ';';
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc_config drop column ' || col_name || ';';
        execute query;
    when modif = 'modif' then
        query = 'alter table ___.'|| b_type ||'_bloc drop column ' || col_name || ';';
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc_config drop column ' || col_name || ';';
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc add column ' || col_name || ' ' || col_type || ' default ' || col_default || ';';
        execute query;
        query = 'alter table ___.'|| b_type ||'_bloc_config add column ' || col_name || ' ' || col_type || ' default ' || col_default ||';';
        execute query;
    else 
        return 'not the write modif';
    end case ;
    return 'Column ' || col_name || ' ' || modif || ' to ' || b_type;
end;
$$;
-- create or replace function api.select_enum_types()
-- returns table(enum_type text) 
-- language plpgsql as
-- $$
-- begin
--     return query
--     select 
--         t.typname::text AS enum_type
--     FROM 
--         pg_type t
--     JOIN 
--         pg_namespace n ON t.typnamespace = n.oid
--     JOIN 
--         pg_enum e ON t.oid = e.enumtypid
--     WHERE 
--         n.nspname = '___'
--     group by t.typname;
-- end;
-- $$ ;

------------------------------------------------------------------------------------------------
-- For calculation 
------------------------------------------------------------------------------------------------


-- select id, sur_bloc, name, formula, inputs, outputs from api.thing_bloc, api.input_output
--         where model = '{model_name}' and api.bloc.b_type = api.input_output.b_type
--         and st_within(sur_b.geom_ref, (select b.geom_ref from api.bloc as b where name = '{bloc}'));
-- but formula is not in bloc nor input_output but in "thing"_bloc where "thing" is b_type
-- create or replace function api.get_blocs(model_name varchar, bloc varchar default null)
-- returns varchar 
-- language plpgsql as
-- $$
-- declare 
--     b_types text ;
--     query text ;
-- begin
--     for b_types in (select b_type from api.input_output)
--     loop
--         query := 'select id, sur_bloc, name, formula, inputs, outputs from api.'|| b_types ||'_bloc, api.input_output ' ||
--         E'where model = '''|| model_name ||''' '||  
--         coalesce(E'shape = ''Polygon'' and st_within(geom, select(geom from api.'||b_types||'_bloc where name='''||bloc||''')));', '') ;
--         raise notice '%', query;
--         execute query ;
--     end loop;
--     return 'ok';
-- end ; 
-- $$;
create or replace function api.get_blocs(model_name varchar, bloc varchar default null)
returns table (
    id integer,
    sur_bloc integer,
    name varchar,
    formula varchar[],
    inp_val jsonb,
    out_val jsonb, 
    formula_details jsonb
) 
language plpgsql as
$$
declare 
    b_types text;
    ids integer;
    ins varchar[];
    outs varchar[];
    query text;
    ins_json text;
    outs_json text;
begin
    -- Create a temporary table to store the results
    create temporary table temp_results (
        id integer,
        sur_bloc integer,
        name varchar,
        formula_name varchar[],
        inp_val jsonb,
        out_val jsonb, 
        formula_details jsonb
    ) on commit drop;

    for b_types in (select b_type from api.input_output)
    loop
        query := 'insert into temp_results(id, sur_bloc, name, formula_name) select id, sur_bloc, name, formula_name from api.' || b_types || '_bloc ' ||
        E'where model = ''' || model_name || ''' ' ||  
        coalesce(E'and shape = ''Polygon'' and st_within(geom, (select geom from api.' || b_types || '_bloc where name=''' || bloc || '''))', '') || ';';
        raise notice '%', query;
        execute query;
    end loop;

    

    for b_types, ins, outs in (select b_type, api.input_output.inputs, api.input_output.outputs from api.input_output)
    loop    
        for ids in (select api.bloc.id from api.bloc 
            where b_type = b_types::___.bloc_type and model = model_name)
        loop
            ins_json := 'jsonb_build_object(' || array_to_string(array(
            select quote_literal(elem) || ', ' || elem
            from unnest(ins) as elem
            union all
            select quote_literal(elem || '_fe') || ', ' || elem || '_fe'
            from unnest(ins) as elem
            where exists (
                select 1
                from information_schema.columns
                where table_schema = 'api'
                and table_name = b_types || '_bloc'
                and column_name = elem || '_fe'
            )
        ), ', ') || ')';

        outs_json := 'jsonb_build_object(' || array_to_string(array(
            select quote_literal(elem) || ', ' || elem
            from unnest(outs) as elem
            union all
            select quote_literal(elem || '_fe') || ', ' || elem || '_fe'
            from unnest(outs) as elem
            where exists (
                select 1
                from information_schema.columns
                where table_schema = 'api'
                and table_name = b_types || '_bloc'
                and column_name = elem || '_fe'
            )
        ), ', ') || ')';

            query := 'with inp as (' ||
                'select ' || ins_json || ' as inp_value ' ||
                'from api.' || b_types || '_bloc where id = ' || ids || '), ' ||
                'out as (' ||
                'select ' || outs_json || ' as out_value ' ||
                'from api.' || b_types || '_bloc where id = ' || ids || ') ' ||
                'update temp_results set inp_val = (select inp_value from inp), out_val = (select out_value from out) ' ||
                'from inp, out where temp_results.id = ' || ids || ';';
            -- raise notice '%', query;
            execute query;
        end loop; 
    end loop; 

    update temp_results
    set formula_details = (
        select jsonb_object_agg(f.formula, f.detail_level)
        from api.formulas f
        where f.name = any(temp_results.formula_name)
    );
    -- Return the results from the temporary table
    return query select * from temp_results;
end; 
$$;


create or replace function api.get_links(model_name varchar)
returns jsonb 
language plpgsql as
$$
declare 
    links jsonb ; 
    downs integer;
    ups jsonb ; 
begin
    -- contruction of a jsonb object with all the ids and null values 
    select jsonb_object_agg(api.bloc.id, null) into links from api.bloc where model = model_name;

    -- update the jsonb object with the links
    for downs, ups in (select down, jsonb_agg(up) from api.link where model = model_name group by down)
    loop
       links := jsonb_set(links, array[downs::text], ups);
    end loop ;
    -- with arrays as (select down, jsonb_agg(up) as ups from api.link where model = model_name group by down)
    -- select jsonb_object_agg(api.bloc.id, ups) into links from api.bloc, arrays
    -- where model = model_name and api.bloc.id = arrays.down;
    return links;
end;
$$;

------------------------------------------------------------------------------------------------
-- Computation 
-- Si on voit que ça prend trop de temps pour améliorer ça, il faut faire moins de tableau temporaires 
------------------------------------------------------------------------------------------------

create or replace function api.pop(fifo varchar, lifo_or_fifo boolean default false) 
returns varchar 
language plpgsql as
$$
declare 
    idx_m integer ; 
    val varchar ;
    query text ;
begin
    if not lifo_or_fifo then
        query := 'select min(id) from '||fifo||';' ;
        execute query into idx_m ;
    else 
        query := 'select max(id) from '||fifo||';' ;
        execute query into idx_m ;
    end if ; 
    query := 'select value from '||fifo||' where id = '||idx_m||' ;' ;
    execute query into val; 
    query := 'delete from '||fifo||' where id = '||idx_m||' ;' ;
    execute query ; 
    return val ; 
end ;
$$ ; 

create or replace function api.recup_entree(id_bloc integer, model_bloc text)
returns boolean
language plpgsql as
$$
declare
    links_up integer[] ;
    b_typ_fils ___.bloc_type ; 
    b_typ ___.bloc_type ;
    query text ;
    colnames varchar[] ;
    col varchar ;
    inp_col real ;
    up integer ;
    flag boolean := false ;
begin 
    select into b_typ_fils b_type from ___.bloc where id = id_bloc ;
    select into links_up array_agg(api.link.up) from api.link where down = id_bloc and model = model_bloc ;    
    if array_length(links_up, 1) = 0 or links_up is null then 
        return false ;
    else 
    foreach up in array links_up loop
        select into b_typ b_type from ___.bloc where id = up ;

        select array_agg(column_name) into colnames from information_schema.columns, api.input_output  
        where table_name = b_typ||'_bloc' and table_schema = 'api' and 
        b_type = b_typ and column_name = any(outputs) ;

        if b_typ::varchar = 'lien' or b_typ::varchar = 'link' then 
            select into links_up array_cat(links_up, array_agg(api.link.up)) from api.link where down = up and model = model_bloc ;
        end if ;
        foreach col in array colnames loop
            query = 'select '||col||' from ___.'||b_typ||'_bloc where id = $1 ;' ;
            execute query into inp_col using up ;
            -- raise notice 'inp_col = %', inp_col ;
            if inp_col is not null then 
                if col like '%_s' then 
                    if left(col, -2) in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then 
                        update inp_out set val = inp_col where name = left(col, -2) and val is null ;
                        if found then 
                            flag := true ;
                        end if ;
                    elseif left(col, -2)||'_e' in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then 
                        update inp_out set val = inp_col where name = left(col, -2)||'_e' and val is null;
                        if found then 
                            flag := true ;
                        end if ;
                    end if ;
                end if ;
                if col in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then
                    update inp_out set val = inp_col where name = col and val is null;
                    if found then 
                        flag := true ;
                    end if ;

                end if ;
            end if ;
        end loop ;
    end loop ;
    end if ;
    return flag ;
end ;
$$ ;

create or replace function api.read_formula(formula text, colnames varchar[])
returns varchar[]
language plpgsql as
$$
declare 
    list varchar[] ;
    to_return varchar[] ;
    pat text ;
begin
    pat := '[\+\-\*\/\^\(\)]' ; 
    formula := replace(formula, ' ', '') ;
    list := regexp_split_to_array(formula, pat) ;
    select into to_return array_agg(elem) from unnest(list) as elem where elem = any(colnames) ;
    return to_return ;
end ;
$$ ;



create or replace function api.calculate_formula(formula text, id_bloc integer, detail_level integer, to_calc varchar)
returns void
language plpgsql as
$$
declare 
    pat varchar := '[\+\-\*\/\^\(\)\>\<]' ;
    rightside text ; 
    operators varchar[] ;
    op varchar ;
    args varchar[] ;
    arg varchar ;
    queries text[] := array['', '', '', '', '', '']::text[] ;
    len integer ;
    to_cast boolean[] := array[false, false, false, false, false]::boolean[] ;
    idx integer ;
    query text ;
    val_arg real ;
    i integer ; 
    j integer := 1 ;
    flag boolean := true ;
    result real ;
    notnowns varchar[] := array[]::varchar[] ; 
    formul text ;
    tic timestamp ;
    tac timestamp ;
begin
    formul := replace(formula, ' ', '') ;
    -- raise notice 'formula = %', formul ;
    rightside := '('||split_part(formul, '=', 2)||')' ;
    -- On met entre parenthèse parce que le code parcours la formule en fonction des parenthèses
    select into operators array_agg(match[1]) from regexp_matches(rightside,  '(\s*[\+\-\*\/\^\(\)\>\<]\s*)', 'g') as match ;
    raise notice 'operators = %', operators ;
    raise notice 'rightside = %', rightside ;
    select into args array_remove(regexp_split_to_array(rightside, pat), '') ;
    raise notice 'args = %', args ;
    idx := 1 ;
    query := '' ;
    len := array_length(queries, 1) ;
    select into notnowns array_agg(name) from inp_out where val is null and name in (select unnest(args)) ;
    -- raise notice 'unknowns = %', notnowns ;
    if array_length(notnowns, 1) > 0 then
        if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then
            update ___.results set val=null, unknowns = notnowns where name = to_calc and ___.results.formula = formul and id = id_bloc ;
        else 
            insert into ___.results(id, name, detail_level, formula, unknowns) values (id_bloc, to_calc, detail_level, formul, notnowns) ;
        end if ; 
    else 
        for i in 1..array_length(operators, 1) loop
            raise notice 'i = %, j = %', i, j ;
            raise notice 'query = %', query ;
            raise notice 'queries = %', queries ;
            if regexp_matches(args[j], '^[0-9]+(\.[0-9]+)?$') is not null then 
                val_arg := args[j]::real ;
            else
                select into val_arg val from inp_out where name = args[j] ;
            end if ; 
            op = operators[i] ;
            case 
            when op = '(' then 
                if idx > len then 
                    queries := array_append(queries, '') ;
                    to_cast := array_append(to_cast, false) ;
                end if ; 
                queries[idx] := query ; 
                query := op||val_arg ;
                j := j + 1 ;
                idx := idx + 1 ;
            when op = '>' or op = '<' then 
                query := query||op||val_arg ; 
                j := j + 1 ;
                to_cast[idx] := true ;
            when op = ')' then
                query := query||op ;
                if to_cast[idx] then 
                    query := query||'::real' ;
                    to_cast[idx] := false ;
                end if ;
                idx := idx - 1 ;
                query := queries[idx]||query ;
            else
                
                query := query||op||val_arg ;
                j := j + 1 ;
            end case ;
        end loop ;
        raise notice 'query = %', query ;
        execute 'select '||query into result ;
        if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then 
            update ___.results set val = result, unknowns = null where name = to_calc and ___.results.formula = formul and id = id_bloc ;
        else
            insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail_level, result, formul) ;
        end if ; 
    end if ;
    return ;
end ;
$$ ;

create or replace function api.calculate_bloc(id_bloc integer, model_bloc text, on_update boolean default false)
returns varchar
language plpgsql as
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
    colnames varchar[] ;
    col varchar ; 
    query text ;
    items record ; 
    flag boolean := true ;
    tic timestamp ;
    tac timestamp ;
begin 
    tic := clock_timestamp() ;
    select into b_typ b_type from ___.bloc where id = id and model = model_bloc ;
    create temp table inp_out(name varchar, val real) on commit drop; 
    -- raise notice 'b_typ = %', b_typ ;
    -- raise notice 'input_output = %', (select inputs from api.input_output where b_type = b_typ) ;
    select array_agg(column_name) into colnames from information_schema.columns, api.input_output  
    where table_name = b_typ||'_bloc' and table_schema = '___' and 
    b_type = b_typ and (column_name = any(inputs) or column_name = any(outputs)) ;
    -- raise notice 'colnames = %', colnames ;
    foreach col in array colnames loop
        query := 'select '''||col||''' as name, '||col||'::real as val from ___.'||b_typ||'_bloc where id = $1 ; '  ; 
        execute query into items using id_bloc ;
        if items.val is null then 
            insert into inp_out(name) values (col) ;
        else
            insert into inp_out(name, val) values (items.name, items.val) ;
        end if ;
    end loop ;
    flag := api.recup_entree(id_bloc, model_bloc) ;
    if not flag and on_update then
        return 'No new entry' ;
    end if ;  

    create temp table bilan(leftside varchar, calc_with varchar[], formula varchar, detail_level integer) on commit drop;
    
    with bloc_formula as (select formula, detail_level from api.formulas where name in (select unnest(default_formulas) from api.input_output where b_type = b_typ))
    insert into bilan(leftside, calc_with, formula, detail_level) 
    select trim(both ' ' from split_part(formula, '=', 1)), api.read_formula(split_part(formula, '=', 2), colnames), formula, detail_level from bloc_formula ;

    create temp table known_data(leftside varchar, known boolean default false) on commit drop;
    insert into known_data(leftside, known) select name, val is not null from inp_out ;

    -- create temp table results(name varchar, detail_level integer, val real) on commit drop ; 
    tac := clock_timestamp() ;
    for data_, args in (select leftside, calc_with from bilan) loop
        create temp table fifo(id serial primary key, value varchar) ; 
        create temp table treatment_lifo(id serial primary key, value varchar) ; 

        insert into fifo(value) values (data_) ;
        c := 0 ; 
        while c < 10000 and (select count(*) from fifo) > 0 loop
            c := c + 1 ;
            to_calc := api.pop('fifo') ;
            -- raise notice 'to_calc = %', to_calc ;
            -- raise notice 'known_data = %', (select known from known_data where leftside = to_calc) ;
            if (to_calc not in (select leftside from known_data where known = true)) and (to_calc in (select leftside from bilan)) then 
                insert into treatment_lifo(value) values (to_calc) ;
                update known_data set known = true where leftside = to_calc ;
                insert into fifo(value) select elem from unnest(args) as elem where elem not in (select leftside from known_data where known = true) ;
            end if ;
        end loop ;
        if c = 10000 then 
            raise exception 'Too many iterations' ;
        end if ;
        c := 0 ; 
        while c < 10000 and (select count(*) from treatment_lifo) > 0 loop
            c := c + 1 ;
            to_calc := api.pop('treatment_lifo', true) ;
            for f, detail in (select formula, detail_level from bilan where leftside = to_calc) loop
                perform api.calculate_formula(f, id_bloc, detail, to_calc) ;
                -- raise notice 'result = %', result ;
                -- insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail, result, f) ;
            end loop ;
            with max_detail as (select max(detail_level) as max_detail from ___.results where name = to_calc and id = id_bloc)
            update inp_out set val = ___.results.val from ___.results, max_detail 
            where inp_out.name = to_calc and ___.results.id = id_bloc and detail = max_detail ; 
        end loop ;
        if c = 10000 then 
            raise exception 'Too many iterations' ;
        end if ;
        drop table fifo ;
        drop table treatment_lifo ;
    end loop ;
    drop table inp_out ;
    drop table bilan ;
    drop table known_data ;
    -- On ne remplie pas les tableaux permanent sur la base de inp_out mais dans l'idée ça pourrait se faire.
    foreach to_calc in array array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c']::varchar[] loop
        if to_calc not in (select name from ___.results where id = id_bloc) then
            insert into ___.results(id, name, val) values (id_bloc, to_calc, 0) ;
        end if ;
    end loop ;
    tac := clock_timestamp() ;
    raise notice 'Time to calculate = %', tac - tic ;
    return 'Calculation done' ;
end ;
$$ ;

create or replace function api.update_calc_bloc(id_bloc integer, model_name varchar, deleted boolean default false)
returns void
language plpgsql
as $$
declare
    downs integer ;
    new_up integer ; 
begin
    create temp table fifo2(id serial primary key, value integer) on commit drop;
    for downs in (select down from api.link where up = id_bloc and model = model_name)
    loop
        insert into fifo2(value) values (downs) ;
    end loop;
    if deleted then
        delete from api.link where up = id_bloc and model = model_name ;
    end if ;
    while (select count(*) from fifo2) > 0
    loop
        new_up := api.pop('fifo2', true) ;
        if deleted then 
            perform api.calculate_bloc(new_up, model_name, false) ; 
        else 
            perform api.calculate_bloc(new_up, model_name, true) ;
        end if ;
        perform api.get_results_ss_bloc(new_up) ;
        perform api.update_results_ss_bloc(new_up, id_bloc) ;
        for downs in (select down from api.link where up = new_up and model = model_name)
        loop
            insert into fifo2(value) values (downs) ;
        end loop ;
    end loop ;
    drop table fifo2 ; 
end ;
$$ ;

create or replace function api.get_results_ss_bloc(id_bloc integer)
returns varchar 
language plpgsql as
$$
declare 
    sb integer ;
    s real ; 
    keys varchar[] := array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c'] ;
    k varchar ;
    f varchar ; 
    item record ;
    flag boolean := true ;
    flag_intrant boolean := false ;
    detail_l integer ; 
    details integer[] ; 
    n_sb boolean;
begin   
    foreach k in array keys loop
        select array_length(ss_blocs, 1) > 0 into n_sb from ___.bloc where id = id_bloc ;
        if n_sb is null or not n_sb then
            update ___.results set result_ss_blocs = val where name = k and id = id_bloc ;
        else
            s := 0 ;
            for sb in (select unnest(ss_blocs) from ___.bloc where id = id_bloc) loop 
                select into details array_agg(detail_level)
                from (
                    select detail_level
                    from ___.results
                    where name = k and id = sb
                    order by detail_level desc
                    limit 2
                ) subquery;
                if details[1] < 6 then
                    details := array[6] ;
                end if ;
                foreach detail_l in array details loop
                    select into item val, result_ss_blocs from ___.results where name = k and id = sb and detail_level = detail_l ;
                    if item.val is not null and item.result_ss_blocs is null then 
                        perform api.get_results_ss_bloc(sb) ;
                        -- Normalement pas de problème parce que si on a cette situation on l'a bien pour toutes les clés 
                        select into item val, result_ss_blocs from ___.results where name = k and id = sb and detail_level = detail_l ;
                    end if ;
                    if detail_l > 6 then -- 6 est le niveua de détail des intrants
                        flag_intrant := true ;
                    end if ;
                    if item.result_ss_blocs is not null then 
                        s := s + item.result_ss_blocs ;
                    else 
                        flag := false ;
                    end if ;
                end loop ;
            end loop ;
            if flag then 
                update ___.results set result_ss_blocs = s where name = k and id = id_bloc ;
            elseif flag_intrant then
                update ___.results set result_ss_blocs = s + val where name = k and id = id_bloc ;
                -- On compte les intrants mais ça ne remplace pas les émissions d'autres formules 
            else
                update ___.results set result_ss_blocs = val where name = k and id = id_bloc ;
            end if ;
        end if ;
    end loop ;
    return 'Results for ss_blocs updated' ;
end ;
$$ ;

create or replace function api.update_results_ss_bloc(id_bloc integer, old_sur_bloc integer, deleted boolean default false)
returns void
language plpgsql as
$$
declare 
    container integer ;
    sb integer ; 
    keys varchar[] := array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c'] ;
    k varchar ;
    f varchar ;
    n_sb boolean;
    s_old real ;
    s_new real ;
    v real ; 
    tic timestamp ; 
    tac timestamp ; 
begin   
    tic := clock_timestamp() ;
    create temp table old_results(id integer, name varchar, result_ss_blocs real) on commit drop ;
    insert into old_results(id, name, result_ss_blocs) select id, name, result_ss_blocs from ___.results where id = id_bloc ;
    select array_length(ss_blocs, 1) > 0 into n_sb from ___.bloc where id = id_bloc ;
    if n_sb is null or not n_sb then
        update ___.results set result_ss_blocs = val where id = id_bloc ;
    end if ; 
    if deleted then
        update ___.results set val = null, result_ss_blocs = null where id = id_bloc ;
        -- raise notice 'Results deleted' ;
    end if ;
    create temp table fifo(id serial primary key, value varchar) on commit drop ;

    insert into fifo(value) values (old_sur_bloc) ;
    sb := id_bloc ; 
    while (select count(*) from fifo) > 0 loop
        container := api.pop('fifo')::integer ;
        insert into old_results(id, name, result_ss_blocs) select id, name, result_ss_blocs from ___.results where name = k and id = container ;
        foreach k in array keys loop
            select into s_old sum(result_ss_blocs) from old_results where name = k and id = sb ;
            select into s_new sum(result_ss_blocs) from ___.results where name = k and id = sb ; 
            -- if k ='co2_e' then
            --     raise notice 'sb = %, container = %', sb, container ;
            --     raise notice 's_old = %, s_new = %', s_old, s_new ;
            -- end if ;
            if s_old != s_new or (s_old is not null and s_new is null) or (s_new is not null and s_old is null) then
                if s_new is null then
                    update ___.results set result_ss_blocs = val where name = k and id = container ;
                elseif s_old is null then 
                    perform api.get_results_ss_bloc(container) ;
                else
                    update ___.results set result_ss_blocs = result_ss_blocs + s_new - s_old where name = k and id = container ;
                end if ;
                insert into fifo(value) select sur_bloc from api.bloc where id = container ;
                sb := container ;
            end if ;
            
        end loop ;
    end loop ;
    drop table fifo ;
    drop table old_results ;
    tac := clock_timestamp() ;
    raise notice 'Time = %', tac - tic ;
    return ;
end ;
$$ ;  
