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
    E'        new.sur_bloc := api.find_sur_bloc(new.id, new.geom_ref, new.model);\n' ||
    E'        new.ss_blocs := api.find_ss_blocs(new.id, new.geom_ref, new.model, new.sur_bloc);\n' ||
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
create or replace function api.find_ss_blocs(id_sur_bloc integer, g geometry, model_name varchar, sur_sur_bloc integer)
returns integer[]
language plpgsql
as $$
declare
    ss_blocs_array integer[];
    id_bloc integer ;
Begin 
    -- raise notice 'finding ss_blocs';
    select array_agg(id) into ss_blocs_array
    from ___.bloc
    where st_within(___.bloc.geom_ref, g) and ___.bloc.model = model_name and not ___.bloc.id = id_sur_bloc;

    -- On enlève les sous-blocs de sous-blocs
    ss_blocs_array := array(
        with b as (
            select id, sur_bloc
            from ___.bloc
        )
        select id
        from unnest(ss_blocs_array) as id
        where id in (
            select b.id
            from b
            where b.sur_bloc is null or not b.sur_bloc = ANY(ss_blocs_array)
        )
    );
    -- raise notice 'ss_blocs_array := %', ss_blocs_array;
    update ___.bloc set sur_bloc = id_sur_bloc where id = any(ss_blocs_array);
    -- On enlève les sous-blocs du tableaux de sous-blocs de l'ancien sur_bloc
    foreach id_bloc in array ss_blocs_array
    loop
        update ___.bloc set ss_blocs = array_remove(ss_blocs, id_bloc) where id = sur_sur_bloc;
    end loop;

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
    b_typ ___.bloc_type;
    line_ record;
    query text ;
    line_bloc record ; 
    p_start geometry;
    p_end geometry;
    sur_bloc1 integer;
    sur_bloc2 integer;
begin 
    -- raise notice 'updating links';
    if shape = 'LineString' then
        select b_type into b_typ from ___.bloc where id = link_id;
        point_up := st_startpoint(g);
        point_down := st_endpoint(g);
-- Y'a peut être possibilité de faire tout en une seule query mais j'ai pas réussi
        for ups in (
            with possible_ids as (select id, geom_ref from ___.bloc 
            where model = model_name and not id = link_id and not st_within(g, geom_ref)
            -- and (b_type != 'lien' or b_typ != 'lien')
            )
            select id from possible_ids where st_intersects(geom_ref, point_up)
            )
        loop
            raise notice 'ups = %, link_id = %', (select name from ___.bloc where id = ups), (select name from ___.bloc where id = link_id);
            insert into ___.link (up, down, model) values (ups, link_id, model_name);
        end loop;
        
        for downs in (
            with possible_ids as (select id, geom_ref from ___.bloc 
            where model = model_name and not id = link_id and not st_within(g, geom_ref)
            -- and (b_type != 'lien' or b_typ != 'lien')
            )
            select id from possible_ids where st_intersects(geom_ref, point_down)
            )
        loop
            raise notice 'downs = %, link_id = %', (select name from ___.bloc where id = downs), (select name from ___.bloc where id = link_id);
            insert into ___.link (up, down, model) values (link_id, downs, model_name);
        end loop;

    else 
        -- link_id n'est plus l'id d'un lien
        -- (dp).path[1] renvoie le numéro de la ligne dans le multipoint et d'après la fonction api.make_polygon,
        -- le premier point dans un linestrig est le startpoint et le deuxième le endpoint  
    for line_bloc in (select id, b_type from ___.bloc where ___.bloc.shape = 'LineString' and model = model_name) loop
        query := 'select geom from ___.'||line_bloc.b_type||'_bloc where id = $1';
        execute query into line_ using line_bloc.id;
        
        p_start := st_startpoint(line_.geom);
        p_end := st_endpoint(line_.geom);

        raise notice 'Intersects = %', st_intersects(g, p_end);

        sur_bloc1 := (select sur_bloc from ___.bloc where id = line_bloc.id);
        sur_bloc2 := (select sur_bloc from ___.bloc where id = link_id);

        if st_intersects(g, p_start) 
        and (link_id != sur_bloc1 or sur_bloc1 is null)
        and (line_bloc.id != sur_bloc2 or sur_bloc2 is null) then
            insert into ___.link (up, down, model) values (link_id, line_bloc.id, model_name);
        end if;

        if st_intersects(g, p_end)
        and (link_id != sur_bloc1 or sur_bloc1 is null)
        and (line_bloc.id != sur_bloc2 or sur_bloc2 is null) then
            raise notice 'BONJOUR';
            insert into ___.link (up, down, model) values (line_bloc.id, link_id, model_name);
        end if;
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
        select array_agg(distinct trim(both ' ' from elem))
        into f_inputs
        from unnest(
            regexp_split_to_array(
                regexp_replace(f, '^[^=]*=', ''), 
                '[\+\-\*\/\^\(\)\>\<]'
            )
        ) as elem;
    -- raise notice 'f_inputs = %', f_inputs;
        f_inputs := array_remove(f_inputs, '');
        f_inputs := array(
            select elem from unnest(f_inputs) as elem
            where not (elem ~ '^[0-9]+$')
        );
        -- raise notice 'f_inputs = %', f_inputs;
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
            select count(inp) as c, array_agg(inp) as ar from unnest(f_inputs) as inp
            where inp not in (select unnest(olds) from inp_out)
        )
        select c=0 into flag from new_inputs; 
    -- raise notice 'flag = %', flag;
    flag := 1 ;
    end if;
    if flag then 
        update ___.input_output
        set default_formulas = array_append(default_formulas, formula_name)
        where b_type = b_type_arg;

        -- On rajoute la formule dans les blocs 
        query := 'update ___.'||b_type_arg||'_bloc set formula_name = array_append(formula_name, '''||formula_name||''')';
        execute query;
        -- On change les valeurs par défaults de la colonne formula_name
        query := 'alter view api.'||b_type_arg||'_bloc alter column formula_name set default array['||coalesce(''''||array_to_string(f_name, ''',''') || ''',', '')||' '''||formula_name||''']';
        raise notice '%', query;
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
        if array_length(formula_to_add, 1) = 0 or formula_to_add is null then 
            return null;
        end if;
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


create or replace function api.select_default_input_output()
returns jsonb
language plpgsql as
$$
declare 
    inps varchar[];
    outs varchar[];
    inp_out varchar[];
    b_typ ___.bloc_type ;
    query text;
    b_typ_json jsonb;
    res jsonb := '{}';
begin
    -- Select inputs and outputs from api.input_output
    for b_typ in (select b_type from api.input_output) 
    loop
        select inputs, outputs into inps, outs
        from api.input_output
        where b_type = b_typ;

        inp_out := array_cat(inps, outs);
        
        with default_values as (
            select column_name, column_default 
            from information_schema.columns 
            where table_name = b_typ || '_bloc' 
            and table_schema = 'api'
            and column_default is not null 
            and data_type != 'USER-DEFINED'
        )
        select jsonb_object_agg(inp, column_default) into b_typ_json
        from default_values, unnest(inp_out) as inp
        where column_name = inp;
        
        if b_typ_json is not null then 
			res := jsonb_set(res, array[b_typ]::text[], b_typ_json, true);
		end if ; 
        end loop ;
    return res;
end
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
