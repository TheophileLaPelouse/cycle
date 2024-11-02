alter type ___.bloc_type add value 'source' ; 
commit ; 
insert into ___.input_output values ('source', array['to_transmit']::varchar[], array['qe_s', 'tbentrant_s', 'tbsortant_s', 'dbo5_s', 'mes_s', 'ngl_s']::varchar[], array[]::varchar[], false) ;

create sequence ___.source_bloc_name_seq ;

create type ___.to_transmit_type as enum ('qe', 'tbentrant', 'tbsortant', 'dbo5', 'mes', 'ngl');

create table ___.source_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('source_bloc', abbreviation=>'source_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],
to_transmit ___.to_transmit_type not null default 'qe',
qe_s real,
tbentrant_s real,
tbsortant_s real,
dbo5_s real,
mes_s real,
ngl_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade,
unique (name, id)
);

create table ___.source_bloc_config(
    like ___.source_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.source_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('source', 'bloc', 'Point');

create or replace function ___.update_source_bloc(id_source integer)
returns void
language plpgsql
as $$
declare
    ups integer[] ;
    n integer ; 
    i integer := 1;
    s real := 0; 
    val real ;
    b_typ ___.bloc_type ;
    col varchar ;
    query text ;
begin 
    select into col to_transmit from api.source_bloc where id = id_source;
    select into ups array_agg(up) from ___.link where down = id_source;
    n := array_length(ups, 1) ;
    while i < n + 1 loop 
        select into b_typ b_type from ___.bloc where id = ups[i];
        -- raise notice 'b_typ = %, col = %', b_typ, col ;
        if b_typ = 'lien' then 
            ups := array_cat(ups, (select array_agg(up) from ___.link where down = ups[i]
             and 'lien' != (select b_type from api.bloc where id = ___.link.up)::varchar));
            n := n + (select count(*) from ___.link where down = ups[i] 
            and 'lien' != (select b_type from api.bloc where id = ___.link.up)::varchar); 
        end if ;
        if col = any((select outputs from api.input_output where b_type = b_typ)::varchar[]) then
            query := 'select '||col||' from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
        elseif col||'_s' = any((select outputs from api.input_output where b_type = b_typ)::varchar[]) then 
            query := 'select '||col||'_s from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
       -- raise notice 's = %, val = %', s, val ;
        end if ; 
        i := i + 1 ;
    end loop ;
    query := 'update api.source_bloc set '||col||'_s = $1 where id = $2';
    -- raise notice 'query = %', query ;
    -- raise notice 's = %', s ;
    execute query using s, id_source;
    return ;
end ;
$$ ;

create or replace function ___.source_link_trigger_function() returns trigger as $$
declare 
    b_typ ___.bloc_type ;
    flag boolean := false ;
    double_down integer ;
begin
    -- raise notice E'\n on est dans le trigger' ;
    select into b_typ b_type from api.bloc where id = new.down ;
    -- raise notice 'b_typ = %', b_typ ;
    if b_typ = 'source' then 
        flag := true ;
        double_down := new.down ;
    end if ;
    if b_typ = 'lien' then 
        for double_down in (select down from ___.link where up = new.down) loop 
            if (select b_type from api.bloc where id = double_down) = 'source' then 
                flag := true ;
                exit ;
            end if ;
        end loop ;
    end if ;
    if flag then 
        -- raise notice 'on y est' ; 
        perform ___.update_source_bloc(double_down);
    end if ;
    return new ;
end ;
$$ language plpgsql ;

create trigger source_link_trigger after insert or update on ___.link for each row execute function ___.source_link_trigger_function() ;


alter type ___.bloc_type add value 'sur_bloc' ;
commit ; 
insert into ___.input_output values ('sur_bloc', array[]::varchar[], array[]::varchar[], array[]::varchar[], false) ;

create sequence ___.sur_bloc_bloc_name_seq ;     




create table ___.sur_bloc_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sur_bloc_bloc', abbreviation=>'sur_bloc_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.sur_bloc_bloc_config(
    like ___.sur_bloc_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.sur_bloc_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('sur_bloc', 'bloc', 'Polygon' 
    
    ) ;




alter type ___.bloc_type add value 'lien' ;
commit ; 
insert into ___.input_output values ('lien', array[]::varchar[], array[]::varchar[], array[]::varchar[], false) ;

create sequence ___.lien_bloc_name_seq ;     




create table ___.lien_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lien_bloc', abbreviation=>'lien_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.lien_bloc_config(
    like ___.lien_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.lien_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('lien', 'bloc', 'LineString' 
    
    ) ;