create extension if not exists postgis;

create schema ___;

comment on schema ___ is 'tables schema for cycle, admin use only';

create or replace function ___.unique_name(concrete varchar, abstract varchar default null, abbreviation varchar default null)
returns varchar
language plpgsql volatile as
$$
declare
    mx integer;
    nxt integer;
    seq varchar;
    tab varchar;
begin
    if abbreviation is null then
        execute format('(select abbreviation from ___.type_%2$s where name=''%1$s'')', concrete, abstract) into abbreviation;
    end if;
    tab := concrete||coalesce('_'||abstract, '');
    seq := tab||'_name_seq';
    nxt := nextval('___.'||seq);
    execute format('with substrings as (
                        select substring(name from ''%2$s_(.*)'') as s
                        from ___.%1$I
                        where name like ''%2$s_%%''
                    )
                    select coalesce(max(s::integer), 1) as mx
                    from substrings
                    where s ~ ''^\d+$'' ',
                    tab, abbreviation) into mx;

    if nxt < mx then
        nxt := mx + 1;
        perform setval('___.'||seq, mx+1);
    end if;
    return abbreviation||'_'||nxt::varchar;
end;
$$
;

------------------------------------------------------------------------------------------------
-- METADATA                                                                                   --
------------------------------------------------------------------------------------------------

create table ___.metadata(
    id integer primary key default 1 check (id=1), -- only one row
    creation_date timestamp not null default now(),
    srid integer references spatial_ref_sys(srid) default 2154,
    unique_name_per_model boolean default true
);

insert into ___.metadata default values;

------------------------------------------------------------------------------------------------
-- ENUMS
-- On crée les types où on peut énumérer des trucs genre pour les données d'entrées                                                                                      --
------------------------------------------------------------------------------------------------

create type ___.zone as enum ('urban', 'rural') ; 

create type ___.geo_type as enum('point', 'line', 'polygon');

------------------------------------------------------------------------------------------------
-- MODELS                                                                                     --
------------------------------------------------------------------------------------------------

create table ___.model(
    name varchar primary key default ___.unique_name('model', abbreviation=>'model') check(not name~' '),
    creation_date timestamp not null default current_date,
    comment varchar
);

------------------------------------------------------------------------------------------------
-- Settings                                                                                   --
-- Pour l'instant y'a rien mais on mettra sûrement des trucs comme les propriétés des matériaux 
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
-- Abstract tables
-- Les tables abstaites sont les tables qui représentent les conceptes généraux : liens, noeuds, blocs.
------------------------------------------------------------------------------------------------


create table ___.bloc(
    id serial primary key,
    name varchar not null check(not name~' '), 
    model varchar not null references ___.model(name) on update cascade on delete cascade,
    shape ___.geo_type not null,
    geom geometry not null ,
    ss_blocs integer[] default array[]::integer[],
    sur_bloc integer default null, -- Pas sûr qu'on garde les surs blocs
    -- est ce qu'il faudrait pas des checks ? 
    unique (name, id, model), 
    unique (name, id, shape), 
    unique (id)
);

create table ___.link(
    -- Peut être que ça va changer mais pour l'instant un lien c'est juste un objet abstrait et tous les blocs sont des noueuds 
    id serial primary key,
    up integer not null references ___.bloc(id) on update cascade on delete cascade,
    down integer not null references ___.bloc(id) on update cascade on delete cascade, 
    unique (id)
);





------------------------------------------------------------------------------------------------
-- Concrete tables
-- Les Blocs que nous allons manipuler dans le logiciel
------------------------------------------------------------------------------------------------

create table ___.test_bloc(
    id serial primary key,
    shape ___.geo_type not null, -- Pour l'instant on dit qu'on fait le type de géométry dans l'api en fonction de ce geo_type.
    name varchar not null default ___.unique_name('test_bloc', abbreviation=>'test_bloc'),
    foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade
);

