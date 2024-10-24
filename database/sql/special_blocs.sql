alter type ___.bloc_type add value 'source' ; 
commit ; 
insert into ___.input_output values ('source', array['to_transmit']::varchar[], array['qe_s', 'tbentrant_s', 'tbsortant_s', 'dbo5_s', 'mes_s', 'ngl_s']::varchar[], array[]::varchar[], true) ;

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
    i integer ;
    s real ; 
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
        if b_typ = 'lien' then 
            ups := array_append(ups, (select up from ___.link where down = ups[i]));
            n := n + 1 ;
        end if ;
        if exists(select 1 from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col) then 
            query := 'select '||col||' from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
        elseif exists(select 1 from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col||'_s') then 
            query := 'select '||col||'_s from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
        i := i + 1 ;
        end if ; 
    end loop ;
    query := 'update api.source_bloc set '||col||'_s = $1 where id = $2';
    execute query using s, id_source;
    return ;
end ;
$$ ;

create or replace function ___.source_link_trigger_function() returns trigger as $$
begin
    if new.down in (select id from api.source_bloc) then 
        perform ___.update_source_bloc(new.down);
    end if ;
    return new ;
end ;
$$ language plpgsql ;

create trigger source_link_trigger after insert or update on ___.link for each row execute function ___.source_link_trigger_function() ;